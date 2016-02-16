json.clients(@clients) do |client|
  json.extract! client, :id, :name, :student, :cpf, :email, :turma, :document, :ref
  json.display_name "#{client.ref} - #{client.name}"
end
