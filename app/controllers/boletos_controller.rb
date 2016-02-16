class BoletosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_boleto, only: [:show, :edit, :update, :destroy]

  def index
    if params[:ref] || params[:doc_number] || params[:date_begin] || params[:date_end]
      @boletos = Boleto.all
      @boletos = @boletos.joins(:client).where(clients: {ref: params[:ref].to_i}) unless params[:ref].empty?
      @boletos = @boletos.where(doc_number: params[:doc_number]) unless params[:doc_number].empty?
      @boletos = @boletos.where('maturity >= :date', date: params["date_begin"]) unless params[:date_begin].empty?
      @boletos = @boletos.where('maturity <= :date', date: params["date_end"]) unless params[:date_end].empty?
    else
      @boletos = Boleto.where(printed: false)
    end
  end

  def new
    @boleto = Boleto.new
  end

   def generate
    @dados_boleto = Boleto.find(params[:format])
    @boleto = Brcobranca::Boleto::Sicredi.new
    @boleto.cedente = "APM DO ColÉGIO MILITAR "
    @boleto.documento_cedente = "01064671000189"
    @boleto.sacado = @dados_boleto.client.name
    @boleto.sacado_documento = @dados_boleto.client.cpf
    @boleto.avalista = "APM DO COLÉGIO MILITAR"
    @boleto.avalista_documento = "01064671000189"
    @boleto.valor = @dados_boleto.amount
    @boleto.agencia = "0911"
    @boleto.conta_corrente = "05945"
    @boleto.variacao = "19"
    @boleto.byte_idt = "2"
    @boleto.posto = "05"
    @boleto.numero_documento = "10402"
    @boleto.data_vencimento = @dados_boleto.maturity.to_date
    @boleto.data_documento = @dados_boleto.date.to_date
    @boleto.instrucao1 = "SR. CAIXA, APÓS O VENCIMENTO NAO COBRAR MULTA, JUROS OU MORA."
    @boleto.instrucao2 = "SR. RESPONSÁVEL, O NAO PAGAMENTO DESTE BOLETO IMPLICARÁ A PERDA DO DESCONTO DO VALOR."
    @boleto.instrucao3 = "VENCIMENTO REFERENTE AO ALUNO: #{@dados_boleto.client.student} / Turma: #{@dados_boleto.client.turma}"

    @boleto.sacado_endereco = @dados_boleto.client.address

    headers['Content-Type']='application/pdf'
    send_data @boleto.to(:pdf), :filename => "boleto.pdf"

    #send_data @boleto.to_b.to(:pdf), :filename => "boleto_#{params[:format]}.#{:pdf}"
  end

  def generate_many
    result = []
    Boleto.where(id: params[:format].split(',')).each do |boleto|
      result << boleto.to_b
    end

    send_data Brcobranca::Boleto::Base.lote(result), filename: "boletos.pdf"
  end

  def edit
  end

  def create
    @boleto = Boleto.new(boleto_params)

    respond_to do |format|
      if @boleto.save
        format.html do
          flash[:success] = "Gerado!"
          redirect_to boletos_path
        end
        format.json { render :show, status: :created, location: @boleto }
      else
        format.html { render :new }
        format.json { render json: @boleto.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @boleto.update(boleto_params)
        format.html do
          flash[:success] = "Atualizado!"
          redirect_to boletos_path
        end
        format.json { render :show, status: :created, location: @boleto }
      else
        format.html { render :index }
        format.json { render json: @boleto.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @boleto.destroy
    head :no_content
  end

  private
  def set_boleto
    @boleto = Boleto.find(params[:id])
  end

  def boleto_params
    params.require(:boleto).permit(:amount, :discount, :date, :maturity, :days_to_maturity, :doc_number, :client_id)
  end
end
