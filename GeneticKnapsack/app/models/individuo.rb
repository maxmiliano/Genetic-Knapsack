class Individuo
  include Comparable

  attr_reader :genoma # Genótipo do indivíduo

  def initialize(problema, bit_string=nil)
    @problema = problema

    if bit_string # se bit_string foi passada como parâmetro, vamos usar
      @genoma = bit_string
    else # senão, escolhemos aleatoriamente
      tmp = rand(2**problema.items.size).to_s(2)
      @genoma = "0" * (problema.items.size - tmp.length) + tmp # completa com zeros
    end

    atualiza_fitness
  end

  def fitness
    # armazena valor de fitness
    @fitness ||= calcula_fitness
  end


  def realizar_mutacao(probabilidade_de_mutacao)
    # flip bits according to mutation probability
    0.upto @genoma.length - 1 do |i|
      if rand < probabilidade_de_mutacao
        @genoma[i] = @genoma[i] == '0' ? '1' : '0'
      end
    end
    atualiza_fitness
  end

  def <=>(other)
    # Troca valores de fitness
    fitness <=> other.fitness
  end

  # O fitness será baseado no valor dos itens, se estes puderem ser levados
  def calcula_fitness

    result = @problema.items.inject({ :valor => 0, :pesos => Array.new(@problema.quantidade_de_compartimentos) {|i| 0} }) do |mem, item|

      # Encontra o índice do bit que representa o item atual (0 = deixa o item; 1 = leva o item)
      bit_correspondente_ao_item = @genoma[@problema.items.find_index(item)].to_i
      # Adiciona o peso (custo) do item em cada compartimento da mochila
      0.upto @problema.quantidade_de_compartimentos - 1 do |compartimento|
        mem[:pesos][compartimento] += item.pesos_em_compartimentos[compartimento].to_i
      end
      # Se os pesos do item não ultrapassam os pesos máximos de cada compartimento
      cabe_na_mochila = true # a princípio, cabe
      0.upto mem[:pesos].length - 1 do |i|
        # Se não couber em, pelo menos, um campartimento, não cabe no mochila
        cabe_na_mochila = cabe_na_mochila && (mem[:pesos][i] <= @problema.pesos_maximos_em_compartimentos[i])
      end

      # Se o item cabe na mochila
      if cabe_na_mochila
        # adicionamos o valor do item ao fitness (observação: valor * 0 = 0)
        mem[:valor] += item.valor * bit_correspondente_ao_item
      end

      mem
    end
    result[:valor]
  end

  def atualiza_fitness
    @fitness = calcula_fitness
  end

end