Sequel.migration do
  change do
    create_table :games do
      primary_key :id
      String :name
      bytea :board
    end
  end
end
