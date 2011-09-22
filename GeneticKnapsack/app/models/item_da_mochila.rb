class ItemDaMochila

  attr_accessor :nome # Descrição do item
  attr_accessor :valor # Balor do benefício
  attr_accessor :pesos_em_compartimentos # Vetor com o peso que o item ocupa em cada compartimento

  def initialize(nome = 'item', valor = 0, pesos_em_compartimentos = Array.new)
    @nome = nome
    @valor = valor
    @pesos_em_compartimentos = pesos_em_compartimentos
  end

end