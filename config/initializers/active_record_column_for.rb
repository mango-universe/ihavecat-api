ActiveRecord::ConnectionAdapters::MySQL::DatabaseStatements::module_eval do
  def column_for(table_name, column_name)
    column_name = column_name.to_s
    columns(table_name).detect { |c| c.name == column_name } || raise(ActiveRecordError, "No such column: #{table_name}.#{column_name}")
  end
end
