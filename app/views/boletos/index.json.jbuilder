json.boletos(@boletos) do |boleto|
  json.extract! boleto, :id, :amount, :discount, :date, :maturity
  json.client boleto.client.name
  json.url boleto_url(boleto, format: :json)
end
