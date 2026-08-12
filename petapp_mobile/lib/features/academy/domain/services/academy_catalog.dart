import 'package:flutter/material.dart';
import 'package:petapp_mobile/features/academy/domain/entities/academy_module.dart';
import 'package:petapp_mobile/features/academy/domain/entities/lesson.dart';
import 'package:petapp_mobile/features/academy/domain/entities/lesson_step.dart';

/// The fixed Academy curriculum: modules and their lessons, as static data —
/// not hardcoded into any screen or widget. Mirrors the `AchievementCatalog`/
/// `MissionCatalog` pattern: a plain catalog-of-defs, queried by id.
///
/// Only `investor_foundations` has real lessons today (Phase 0 — see
/// `docs/ACADEMY_ENGINE.md`). The remaining modules are declared with
/// `contentAvailable: false` so the full curriculum shape (and progression
/// system) is visible without shipping unwritten/unvalidated content.
class AcademyCatalog {
  const AcademyCatalog._();

  static const List<AcademyModule> modules = [
    AcademyModule(
      id: 'investor_foundations',
      title: 'Fundamentos do Investidor',
      description: 'A linguagem básica de investir: poupar x investir, patrimônio, inflação, juros compostos, risco e diversificação.',
      icon: Icons.rocket_launch_outlined,
      order: 1,
      lessonIds: [
        'foundations_what_is_investing',
        'foundations_assets_liabilities',
        'foundations_inflation',
        'foundations_compound_interest',
        'foundations_risk_return',
        'foundations_diversification',
      ],
      contentAvailable: true,
    ),
    AcademyModule(
      id: 'fixed_income',
      title: 'Renda Fixa',
      description: 'Como funcionam CDBs, Tesouro Direto, LCI/LCA e os conceitos de liquidez, prazo e risco de crédito.',
      icon: Icons.shield_outlined,
      order: 2,
    ),
    AcademyModule(
      id: 'stocks',
      title: 'Ações e Renda Variável',
      description: 'O que significa ser sócio de uma empresa: preço, valor de mercado, lucro, dividendos e volatilidade.',
      icon: Icons.trending_up,
      order: 3,
    ),
    AcademyModule(
      id: 'fundamental_analysis',
      title: 'Análise Fundamentalista',
      description: 'P/L, P/VP, ROE, margens e endividamento — ferramentas para investigar uma empresa, não sinais de compra.',
      icon: Icons.analytics_outlined,
      order: 4,
    ),
    AcademyModule(
      id: 'etfs',
      title: 'ETFs e Diversificação',
      description: 'Exposição a dezenas de empresas de uma vez: como funcionam os fundos de índice.',
      icon: Icons.pie_chart_outline,
      order: 5,
    ),
    AcademyModule(
      id: 'crypto',
      title: 'Criptoativos',
      description: 'Bitcoin, blockchain e os riscos específicos de custódia e volatilidade — com responsabilidade.',
      icon: Icons.currency_bitcoin,
      order: 6,
    ),
    AcademyModule(
      id: 'portfolio_construction',
      title: 'Monte sua Carteira',
      description: 'Perfil de risco, horizonte de tempo e alocação entre renda fixa, ações e ETFs.',
      icon: Icons.dashboard_customize_outlined,
      order: 7,
    ),
  ];

  static const List<Lesson> _lessons = [
    Lesson(
      id: 'foundations_what_is_investing',
      moduleId: 'investor_foundations',
      title: 'O que é Investir?',
      order: 1,
      xpReward: 20,
      steps: [
        ExplanationStep(
          title: 'Poupar x Investir',
          body:
              'Investir é diferente de guardar dinheiro. Poupar é deixar o dinheiro parado; investir é fazer esse '
              'dinheiro trabalhar para gerar mais dinheiro ao longo do tempo, aceitando algum risco em troca de um '
              'retorno potencial.',
        ),
        ExampleStep(
          title: 'Na prática',
          body:
              'Se você guarda R\$100 debaixo do colchão, daqui a 1 ano ainda são R\$100. Se você investe esses R\$100 '
              'a uma taxa de 10% ao ano, você passa a ter R\$110.',
        ),
        ChoiceQuestionStep(
          framing: ChoiceStepFraming.microExercise,
          prompt: 'Qual a principal diferença entre poupar e investir?',
          options: [
            'Poupar sempre rende mais',
            'Investir envolve assumir algum risco em busca de retorno',
            'Não há diferença',
            'Poupar é proibido no Brasil',
          ],
          correctIndex: 1,
          explanation:
              'Investir significa aceitar algum grau de risco na expectativa de um retorno maior do que apenas '
              'guardar o dinheiro parado.',
        ),
        ChoiceQuestionStep(
          framing: ChoiceStepFraming.apply,
          prompt:
              'Você recebeu um dinheiro extra e não vai precisar dele nos próximos 5 anos. O que faz mais sentido '
              'investigar primeiro?',
          options: [
            'Qual investimento promete o maior retorno, sem mais perguntas',
            'Seus objetivos, prazo e o quanto de risco você aceita correr',
            'Onde seus amigos estão investindo',
            'Qual investimento está em alta nas redes sociais',
          ],
          correctIndex: 1,
          explanation:
              'Antes de escolher onde investir, é essencial entender seus próprios objetivos, prazo e tolerância a '
              'risco — o investimento certo depende de você, não apenas do produto.',
        ),
        SummaryStep(
          title: 'O que você aprendeu',
          takeaways: [
            'Poupar é guardar dinheiro parado; investir é buscar fazê-lo crescer.',
            'Investir envolve aceitar algum risco em troca de retorno potencial.',
            'Entender seus objetivos vem antes de escolher onde investir.',
          ],
        ),
      ],
    ),
    Lesson(
      id: 'foundations_assets_liabilities',
      moduleId: 'investor_foundations',
      title: 'Ativos, Passivos e Patrimônio',
      order: 2,
      xpReward: 20,
      steps: [
        ExplanationStep(
          title: 'Duas colunas',
          body:
              'Um ativo é algo que coloca dinheiro no seu bolso ou tem potencial de valorizar — como uma ação ou um '
              'imóvel alugado. Um passivo é algo que tira dinheiro do seu bolso, como uma dívida. Seu patrimônio '
              'líquido é a diferença entre tudo o que você possui (ativos) e tudo o que você deve (passivos).',
        ),
        ExampleStep(
          title: 'Na prática',
          body: 'Se você tem R\$5.000 investidos (ativo) e R\$2.000 de dívida no cartão (passivo), seu patrimônio líquido é R\$3.000.',
        ),
        ChoiceQuestionStep(
          framing: ChoiceStepFraming.microExercise,
          prompt: 'Qual das opções abaixo é um passivo?',
          options: [
            'Uma ação que você comprou',
            'Um financiamento de carro em aberto',
            'Dinheiro guardado na poupança',
            'Um imóvel quitado',
          ],
          correctIndex: 1,
          explanation: 'Um financiamento em aberto tira dinheiro do seu bolso todo mês — por isso é um passivo.',
        ),
        ChoiceQuestionStep(
          framing: ChoiceStepFraming.apply,
          prompt:
              'Duas pessoas ganham o mesmo salário. Uma tem patrimônio líquido crescente; a outra, decrescente. O '
              'que provavelmente explica essa diferença?',
          options: [
            'A sorte',
            'Como cada uma administra a relação entre ativos e passivos ao longo do tempo',
            'Apenas o salário importa',
            'Não há explicação possível',
          ],
          correctIndex: 1,
          explanation:
              'Patrimônio não depende só de quanto você ganha, mas de como você equilibra o que possui com o que '
              'deve, mês após mês.',
        ),
        SummaryStep(
          title: 'O que você aprendeu',
          takeaways: [
            'Ativos colocam dinheiro no seu bolso; passivos tiram.',
            'Patrimônio líquido = ativos − passivos.',
            'Acompanhar essa equação ao longo do tempo é mais revelador do que olhar só o salário.',
          ],
        ),
      ],
    ),
    Lesson(
      id: 'foundations_inflation',
      moduleId: 'investor_foundations',
      title: 'Inflação e Poder de Compra',
      order: 3,
      xpReward: 20,
      steps: [
        ExplanationStep(
          title: 'O que é inflação',
          body:
              'Inflação é o aumento geral dos preços ao longo do tempo, que reduz o poder de compra do seu dinheiro. '
              'Se sua renda não cresce pelo menos na mesma proporção, você consegue comprar cada vez menos com o '
              'mesmo valor.',
        ),
        ExampleStep(
          title: 'Na prática',
          body:
              'Se um produto custava R\$100 e a inflação do ano foi de 5%, esse mesmo produto passa a custar R\$105. '
              'Se seu dinheiro parado não rendeu nada, ele agora compra menos do que antes.',
        ),
        ChoiceQuestionStep(
          framing: ChoiceStepFraming.microExercise,
          prompt:
              'Se a inflação de um ano foi de 6% e seu investimento rendeu 4% no mesmo período, o que aconteceu com '
              'seu poder de compra?',
          options: [
            'Aumentou',
            'Ficou igual',
            'Diminuiu, mesmo com retorno positivo',
            'É impossível saber',
          ],
          correctIndex: 2,
          explanation:
              'Quando o retorno fica abaixo da inflação, o chamado retorno real é negativo — seu dinheiro rendeu, '
              'mas perdeu poder de compra.',
        ),
        ChoiceQuestionStep(
          framing: ChoiceStepFraming.apply,
          prompt:
              'Você está escolhendo entre deixar dinheiro parado na conta corrente ou investir em algo que '
              'acompanhe a inflação. Por que isso importa no longo prazo?',
          options: [
            'Não importa, dinheiro parado nunca perde valor',
            'Porque, ao longo dos anos, a inflação corrói o valor real de dinheiro parado',
            'Porque a inflação só afeta grandes quantias',
            'Porque é apenas uma questão psicológica',
          ],
          correctIndex: 1,
          explanation:
              'Ao longo dos anos, mesmo uma inflação moderada reduz bastante o poder de compra de dinheiro que fica '
              'parado sem render.',
        ),
        SummaryStep(
          title: 'O que você aprendeu',
          takeaways: [
            'Inflação reduz o poder de compra do dinheiro ao longo do tempo.',
            'Retorno real = retorno obtido − inflação do período.',
            'Deixar dinheiro parado tem um custo invisível, mas real.',
          ],
        ),
      ],
    ),
    Lesson(
      id: 'foundations_compound_interest',
      moduleId: 'investor_foundations',
      title: 'Juros Compostos',
      order: 4,
      xpReward: 20,
      steps: [
        ExplanationStep(
          title: 'Juros sobre juros',
          body:
              'Juros compostos são calculados sobre o valor original mais os juros já acumulados — você passa a '
              'ganhar juros sobre juros. Isso faz o dinheiro crescer de forma acelerada, especialmente quanto mais '
              'tempo ele fica investido.',
        ),
        ExampleStep(
          title: 'Na prática',
          body:
              'R\$1.000 investidos a 10% ao ano viram R\$1.100 no primeiro ano. No segundo ano, os 10% incidem sobre '
              'R\$1.100, não mais sobre R\$1.000 — resultando em R\$1.210.',
        ),
        ChoiceQuestionStep(
          framing: ChoiceStepFraming.microExercise,
          prompt: 'O que mais potencializa o efeito dos juros compostos?',
          options: [
            'Investir uma única vez e esquecer',
            'O tempo que o dinheiro permanece investido',
            'Trocar de investimento com frequência',
            'Investir apenas grandes quantias',
          ],
          correctIndex: 1,
          explanation:
              'O tempo é o ingrediente mais importante dos juros compostos — quanto mais tempo o dinheiro fica '
              'investido, maior o efeito acumulado.',
        ),
        ChoiceQuestionStep(
          framing: ChoiceStepFraming.apply,
          prompt:
              'Duas pessoas investem o mesmo valor mensal, à mesma taxa. Uma começa aos 25 anos, a outra aos 35. Por '
              'que a primeira tende a terminar com bem mais dinheiro?',
          options: [
            'Porque teve mais sorte',
            'Porque seus juros tiveram mais tempo para compor',
            'Porque investiu em ativos diferentes',
            'Não há diferença relevante',
          ],
          correctIndex: 1,
          explanation:
              'Dez anos a mais de juros compondo sobre juros fazem uma diferença enorme no resultado final — esse é '
              'o poder do tempo combinado com consistência.',
        ),
        SummaryStep(
          title: 'O que você aprendeu',
          takeaways: [
            'Juros compostos são juros sobre juros já acumulados.',
            'O tempo investido é o fator mais poderoso desse efeito.',
            'Começar cedo, mesmo com pouco, tende a valer mais do que começar tarde com mais.',
          ],
        ),
      ],
    ),
    Lesson(
      id: 'foundations_risk_return',
      moduleId: 'investor_foundations',
      title: 'Risco e Retorno',
      order: 5,
      xpReward: 20,
      steps: [
        ExplanationStep(
          title: 'Dois lados da mesma moeda',
          body:
              'Risco e retorno costumam andar juntos: investimentos com potencial de retorno mais alto geralmente '
              'envolvem maior risco de oscilação ou perda. Não existe retorno alto garantido sem algum risco '
              'envolvido.',
        ),
        ExampleStep(
          title: 'Na prática',
          body:
              'Um investimento que promete o dobro do retorno médio do mercado, sem nenhum risco aparente, deve ser '
              'investigado com cautela — normalmente esse equilíbrio não existe.',
        ),
        ChoiceQuestionStep(
          framing: ChoiceStepFraming.microExercise,
          prompt: 'Um investimento com retorno esperado maior é sempre a melhor escolha?',
          options: [
            'Sim, quanto maior o retorno, melhor',
            'Não, porque o retorno mais alto costuma vir acompanhado de mais risco ou menos liquidez',
            'Sim, desde que esteja em alta no momento',
            'Não, porque investimentos com maior retorno são sempre golpes',
          ],
          correctIndex: 1,
          explanation:
              'Um retorno maior normalmente envolve mais risco, volatilidade ou menos liquidez — a "melhor" escolha '
              'depende do seu objetivo e tolerância a risco, não apenas do número.',
        ),
        ChoiceQuestionStep(
          framing: ChoiceStepFraming.apply,
          prompt:
              'Liquidez é a facilidade de transformar um investimento em dinheiro disponível. Por que ela importa '
              'ao lado de risco e retorno?',
          options: [
            'Não é importante',
            'Porque um investimento pode ter bom retorno, mas ser difícil de resgatar quando você precisar do dinheiro',
            'Porque liquidez é sempre garantia de segurança',
            'Porque só investimentos líquidos rendem',
          ],
          correctIndex: 1,
          explanation:
              'Mesmo um bom investimento pode não servir para você se o dinheiro ficar preso justamente quando você '
              'precisar dele — liquidez é parte da equação.',
        ),
        SummaryStep(
          title: 'O que você aprendeu',
          takeaways: [
            'Risco e retorno costumam estar relacionados.',
            'Um retorno mais alto não é automaticamente "melhor" — depende do seu contexto.',
            'Liquidez também importa: considere quando você pode precisar do dinheiro de volta.',
          ],
        ),
      ],
    ),
    Lesson(
      id: 'foundations_diversification',
      moduleId: 'investor_foundations',
      title: 'Diversificação',
      order: 6,
      xpReward: 20,
      steps: [
        ExplanationStep(
          title: 'Não coloque tudo no mesmo lugar',
          body:
              'Diversificar é distribuir seus investimentos entre diferentes ativos, setores ou tipos de '
              'investimento, em vez de concentrar tudo em um único lugar. O objetivo não é eliminar o risco, mas '
              'reduzir o impacto de um único investimento ir mal.',
        ),
        ExampleStep(
          title: 'Na prática',
          body:
              'Se você investe tudo em uma única empresa e ela enfrenta dificuldades, todo o seu patrimônio sofre. '
              'Se você distribui entre várias empresas e tipos de ativos, o impacto de um problema isolado tende a '
              'ser menor.',
        ),
        ChoiceQuestionStep(
          framing: ChoiceStepFraming.microExercise,
          prompt: 'Qual o principal objetivo da diversificação?',
          options: [
            'Garantir que você nunca terá prejuízo',
            'Reduzir o impacto de um investimento específico ir mal no total da carteira',
            'Aumentar garantidamente o retorno',
            'Simplificar a carteira ao máximo',
          ],
          correctIndex: 1,
          explanation:
              'Diversificar não elimina risco nem garante lucro — ajuda a reduzir o impacto de um problema isolado '
              'sobre o conjunto da carteira.',
        ),
        ChoiceQuestionStep(
          framing: ChoiceStepFraming.apply,
          prompt: 'Você já entende poupar x investir, patrimônio, inflação e risco. Como isso ajuda a pensar em diversificação?',
          options: [
            'Escolhendo apenas o ativo que parece mais na moda no momento',
            'Considerando como diferentes tipos de investimento podem se comportar de formas diferentes diante do mesmo cenário',
            'Não faz diferença, todos os ativos se comportam igual',
            'Diversificação só existe para grandes investidores',
          ],
          correctIndex: 1,
          explanation:
              'Ativos diferentes reagem de formas diferentes aos mesmos eventos econômicos — é justamente essa '
              'diferença que torna a diversificação útil.',
        ),
        SummaryStep(
          title: 'Módulo concluído!',
          takeaways: [
            'Diversificar é distribuir investimentos entre diferentes ativos e categorias.',
            'O objetivo é reduzir o impacto de um problema isolado, não eliminar risco.',
            'Você já tem a base para começar a explorar renda fixa e ações.',
          ],
        ),
      ],
    ),
  ];

  static AcademyModule? moduleById(String id) {
    for (final module in modules) {
      if (module.id == id) return module;
    }
    return null;
  }

  static Lesson? lessonById(String id) {
    for (final lesson in _lessons) {
      if (lesson.id == id) return lesson;
    }
    return null;
  }

  static List<Lesson> lessonsForModule(String moduleId) {
    final result = _lessons.where((l) => l.moduleId == moduleId).toList();
    result.sort((a, b) => a.order.compareTo(b.order));
    return result;
  }

  /// XP already earned across [completedLessonIds] — unknown ids contribute
  /// nothing, matching `AchievementCatalog.totalXpFor`'s defensive style.
  static int xpEarnedFor(Set<String> completedLessonIds) {
    return _lessons.where((l) => completedLessonIds.contains(l.id)).fold(0, (sum, l) => sum + l.xpReward);
  }
}
