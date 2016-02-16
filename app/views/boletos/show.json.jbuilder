json.extract! @boleto, :id, :amount, :discount, :date, :maturity, :doc_number, :created_at, :updated_at
json.client @boleto.client.name
