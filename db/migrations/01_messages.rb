Sequel.migration do
  change do
    create_table :messages do
      primary_key :idea
      String :content, text: true
      DateTime :created_at
    end
  end
end
