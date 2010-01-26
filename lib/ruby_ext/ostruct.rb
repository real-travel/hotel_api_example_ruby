require 'ostruct'

class OpenStruct
  def id_with_table
    @table[:id] || id_without_table
  end
  alias_method :id_without_table, :id
  alias_method :id, :id_with_table
end