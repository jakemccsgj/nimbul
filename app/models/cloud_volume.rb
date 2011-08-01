class CloudVolume < CloudResource
    # auditing
    has_many :audit_logs, :as => :auditable, :dependent => :nullify

    def self.default_mount_type
        'MountVolumeMountType'
    end

    def available?
        state == 'available'
    end
    
    def allocate!
        if self.save
            begin
                size_or_snapshot = self.size.blank? ? self.parent_cloud_id : self.size
                res = Ec2Adapter.create_volume(self, size_or_snapshot, self.zone)
                self.update_attributes(res)
                return true
            rescue Exception => e
                msg = "Failed to allocate volume '#{self.name}' [#{self.id}]: #{e.message}"
                Rails.logger.error msg+"\n\t#{e.backtrace.join("\n\t")}"
                errors.add_to_base "#{msg}"
                self.destroy
                return false
            end
        else
            return false
        end
    end

    def snapshot!(suffix = Time.now.to_s(:volume_snapshot_name))
        snapshot_name = suffix.blank? ? self.name : self.name+' '+suffix
        snapshot = self.provider_account.snapshots.build({
            :name => snapshot_name,
        })
        # expose this snapshot to all the clusters the original volume is exposed to
        snapshot.clusters = (self.clusters) unless self.clusters.empty?
        if snapshot.save
            begin
                res = Ec2Adapter.create_snapshot(self)
                snapshot.update_attributes(res)
            rescue Exception => e
                msg = "Failed to snapshot volume '#{self.name}' [#{self.id}]: #{e.message}"
                Rails.logger.error msg+"\n\t#{e.backtrace.join("\n\t")}"
                snapshot.destroy
                errors.add_to_base "#{msg}"
                return nil
            end
        end
        return snapshot
    end

    def delete!
        if self.destroy
            begin
                Ec2Adapter.delete_volume(self)
            rescue Exception => e
                msg = "Failed to delete volume '#{self.name}' [#{self.id}]: #{e.message}"
                Rails.logger.error msg+"\n\t#{e.backtrace.join("\n\t")}"
                errors.add_to_base "#{msg}"
                return false
            end
        else
            return false
        end
        
        return true
    end

    def self.create_from(volume)
        a = new({
            :provider_account_id => volume.provider_account_id,
            :zone_id => volume.zone_id,
            :cloud_id => volume.volume_id,
            :name => volume.name,
            :state => volume.status,
            :size => volume.size,
            :parent_cloud_id => volume.snapshot_id,
            :is_enabled => volume.is_enabled,
            :cloud_instance_id => volume.instance_id,            
        })
        a.save
    end
end
