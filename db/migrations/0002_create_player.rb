Sequel.migration do
  change do
    create_table :users do
      primary_key :id
      String :name
      String :salt, null: false
      String :password_hash, null: false
    end
  end
end
