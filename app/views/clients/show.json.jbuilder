json.extract! @client, :id, :name, :document, :student, :cpf, :email, :turma , :ref, :created_at, :updated_at
json.display_name "#{@client.ref} - #{@client.name}"
