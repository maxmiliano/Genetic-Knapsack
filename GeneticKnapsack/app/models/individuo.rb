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
        @genoma[i, 1] = @genoma[i] == '0' ? '1' : '0'
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

    # Vamos reparar o Genoma antes de calcular seu fitness
    self.repara_genoma unless self.factivel?

    result = @problema.items.inject({ :valor => 0, :pesos => Array.new(@problema.quantidade_de_compartimentos) {|i| 0} }) do |mem, item|

      # Encontra o índice do bit que representa o item atual (0 = deixa o item; 1 = leva o item)
      bit_correspondente_ao_item = @genoma[@problema.items.find_index(item), 1].to_i

      # Se os pesos do item não ultrapassam os pesos máximos de cada compartimento
      cabe_na_mochila = true # a princípio, cabe
      0.upto mem[:pesos].length - 1 do |i|
        # Para caber na mochila, tem que caber em todos os compartimentos, considerando o  peso já acumulado
        cabe_na_mochila = cabe_na_mochila && ((mem[:pesos][i] + item.pesos_em_compartimentos[i]) <= @problema.pesos_maximos_em_compartimentos[i])
      end

      # Se o item cabe na mochila
      if cabe_na_mochila

        # Adiciona o peso (custo) do item em cada compartimento da mochila
        0.upto @problema.quantidade_de_compartimentos - 1 do |compartimento|
          mem[:pesos][compartimento] += item.pesos_em_compartimentos[compartimento] * bit_correspondente_ao_item
        end

        # adicionamos o valor do item ao fitness (observação: valor * 0 = 0)
        mem[:valor] += item.valor * bit_correspondente_ao_item
      end

      mem
    end
    result[:valor]
  end

  def factivel?

    pesos_acumulados = Array.new(@problema.quantidade_de_compartimentos) {|i| 0}

    @problema.items.each do |item|

      # Encontra o índice do bit que representa o item atual (0 = deixa o item; 1 = leva o item)
      bit_correspondente_ao_item = @genoma[@problema.items.find_index(item), 1].to_i

      0.upto @problema.quantidade_de_compartimentos - 1 do |compartimento|
        pesos_acumulados[compartimento] += (item.pesos_em_compartimentos[compartimento] * bit_correspondente_ao_item)

        # Se uma parte de um item já não cabe na mochila, o indivíduo é infactível!
        return false if (pesos_acumulados[compartimento] > @problema.pesos_maximos_em_compartimentos[compartimento])
      end
    end

    # Se não encontrou nenhum problema, a solução é factível
    return true

  end

  # Repara o genompa para que se torne uma solução factível
  def repara_genoma

    # Enquanto não for factível
    while !factivel? do
      # Sorteamos 3 genes
      rand_range = @genoma.length - 1

      indice_do_gene_alterado = rand(rand_range)
      @genoma[indice_do_gene_alterado, 1] = "0"

      indice_do_gene_alterado = rand(rand_range)
      @genoma[indice_do_gene_alterado, 1] = "0"

      indice_do_gene_alterado = rand(rand_range)
      @genoma[indice_do_gene_alterado, 1] = "0"


    end

    true

  end

  def atualiza_fitness
    @fitness = calcula_fitness
  end

end