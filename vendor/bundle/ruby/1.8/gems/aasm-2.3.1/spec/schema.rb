ActiveRecord::Schema.define(:version => 0) do

  %w{gates readers writers transients simples thieves localizer_test_models}.each do |table_name|
    create_table table_name, :force => true
  end

end
