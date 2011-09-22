class GeneticKnapSack
  attr_reader :opts, :populacao, :contador_de_geracao

  def initialize(problema, opts = {})
    @opts = {
      :tamanho_da_populacao => 100,
      :probabilidade_de_recombinacao => 0.7,
      :probabilidade_de_mutacao => 2 / problema.items.size,
      :quantidade_maxima_de_geracoes => 100,
      :verbose => true,
      :quantidade_maxima_de_geracoes_sem_melhoria => 10,
      :usar_cruzamento_em_dois_pontos => false
    }.merge! opts

    @problema = problema
    @populacao = Array.new(@opts[:tamanho_da_populacao]) {|i| Individuo.new problema}
  end

  def run
    melhor_media_pior = [] # Armazena o melhor, a média e o pior de cada geração
    melhor = melhor_atual # Guarda o melhor
    i = 0
    quantidade_de_geracoes_sem_melhoria = 0
    @contador_de_geracao = 0
    while quantidade_de_geracoes_sem_melhoria < @opts[:quantidade_maxima_de_geracoes_sem_melhoria] && i <= @opts[:quantidade_maxima_de_geracoes] do

      if @opts[:verbose]
        puts "----------------------------"
        puts "Iniciando Geracao #{i}"
        puts "Melhor individuo: #{melhor.genoma} \n com fitness: #{melhor.fitness}"
        #puts "Média: #{@population.inject(0) {|mem, obj| mem + obj.valor}}
      end

      novo_melhor = evolua # create new generation
      quantidade_de_geracoes_sem_melhoria += 1

      # Se a nova geração possui um indivíduo melhor
      if novo_melhor > melhor
        # não temos mais "gerações sem melhoria" para contar.
        melhor = novo_melhor
        quantidade_de_geracoes_sem_melhoria = 0
      end

      media = @populacao.inject(0) {|mem, item| mem + item.fitness } / @populacao.size
      pior = pior_atual

      melhor_media_pior[i] = [melhor.fitness, media, pior.fitness] #"#{best.fitness}, #{media}, #{pior.fitness}"

      if @opts[:verbose]
        puts "Pior individuo: #{pior.genoma} \n com fitness: #{pior.fitness}"
        puts "Media da populacao: #{media} "
        puts "----------------------------"
      end


      i += 1
      @contador_de_geracao += 1
    end
    [melhor, melhor_media_pior]
  end

  def evolua
    @populacao = proxima_geracao
    @populacao.each {|p| p.realizar_mutacao @opts[:probabilidade_de_mutacao]}
    melhor_atual
  end

  def melhor_atual
    @populacao.sort.last
  end

  def pior_atual
    @populacao.sort.first
  end

  def proxima_geracao
    @nova_populacao = []
    while @nova_populacao.size < @opts[:tamanho_da_populacao] do
      @nova_populacao.concat get_offspring
    end
    @nova_populacao[0..(@opts[:tamanho_da_populacao] - 1)]
  end

  def get_offspring
    pai_1 = selecione_pai
    pai_2 = selecione_pai

    if rand < @opts[:probabilidade_de_recombinacao]
      realize_cruzamento pai_1, pai_2
    else
      [pai_1, pai_2]
    end
  end

  def realize_cruzamento(pai_1, pai_2)
    rand_range = pai_1.genoma.length - 1

    offspring_1, offspring_2 = nil, nil

    if(@opts[:usar_cruzamento_em_dois_pontos])
      crossover_points = [rand(rand_range), rand(rand_range)].sort
      genoma1 = pai_1.genoma
      genoma2 = pai_2.genoma
      offspring_1 = genoma1[0..crossover_points[0]] + genoma2[(crossover_points[0]+1)..crossover_points[1]] + genoma1[(crossover_points[1]+1)..-1]
      offspring_2 = genoma2[0..crossover_points[0]] + genoma1[(crossover_points[0]+1)..crossover_points[1]] + genoma2[(crossover_points[1]+1)..-1]
    else
      crossover_point = rand(rand_range)
      offspring_1 = pai_1.genoma[0..crossover_point] + pai_2.genoma[(crossover_point + 1)..-1]
      offspring_2 = pai_2.genoma[0..crossover_point] + pai_1.genoma[(crossover_point + 1)..-1]
    end

    [Individuo.new(@problema, offspring_1), Individuo.new(@problema, offspring_2)]
  end

  def selecione_pai
    opponent_1 = @populacao[rand @populacao.size]
    opponent_2 = @populacao[rand @populacao.size]
    opponent_1 >= opponent_2 ? opponent_1 : opponent_2
  end
end