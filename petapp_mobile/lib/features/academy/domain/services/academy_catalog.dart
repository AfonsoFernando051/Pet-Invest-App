import 'package:flutter/material.dart';
import 'package:petrimonium/core/utils/translator.dart';
import 'package:petrimonium/features/academy/domain/entities/academy_module.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson.dart';
import 'package:petrimonium/features/academy/domain/entities/lesson_step.dart';

/// The fixed Academy curriculum: modules and their lessons, as static data —
/// not hardcoded into any screen or widget. Mirrors the `AchievementCatalog`/
/// `MissionCatalog` pattern: a plain catalog-of-defs, queried by id.
///
/// pt-BR is the default and only content available if no language override
/// applies; `Translator.currentLanguage` (set only via Settings, never
/// auto-detected) selects which of the three parallel content tables below
/// is used, mirroring `Translator._localizedValues`'s own per-language map
/// shape. Curriculum text lives here — colocated with its catalog, like
/// `MissionCatalog`/`AchievementCatalog` — rather than in the shared
/// `AppStrings`/`Translator` files, which are reserved for generic UI chrome.
///
/// Only `investor_foundations` has real lessons today (Phase 0 — see
/// `docs/ACADEMY_ENGINE.md`). The remaining modules are declared with
/// `contentAvailable: false` so the full curriculum shape (and progression
/// system) is visible without shipping unwritten/unvalidated content.
class AcademyCatalog {
  const AcademyCatalog._();

  static List<AcademyModule> get modules {
    return switch (Translator.currentLanguage) {
      'en' => _modulesEn,
      'es' => _modulesEs,
      _ => _modulesPt,
    };
  }

  static List<Lesson> get _lessons {
    return switch (Translator.currentLanguage) {
      'en' => _lessonsEn,
      'es' => _lessonsEs,
      _ => _lessonsPt,
    };
  }

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
  /// XP rewards are language-independent, so this reads from the pt table
  /// regardless of the active language.
  static int xpEarnedFor(Set<String> completedLessonIds) {
    return _lessonsPt.where((l) => completedLessonIds.contains(l.id)).fold(0, (sum, l) => sum + l.xpReward);
  }

  // ── Modules ────────────────────────────────────────────────────────────

  static const List<AcademyModule> _modulesPt = [
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

  static const List<AcademyModule> _modulesEn = [
    AcademyModule(
      id: 'investor_foundations',
      title: 'Investor Foundations',
      description: 'The basic language of investing: saving vs. investing, net worth, inflation, compound interest, risk and diversification.',
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
      title: 'Fixed Income',
      description: 'How CDBs, Treasury bonds and LCI/LCA work, and the concepts of liquidity, term and credit risk.',
      icon: Icons.shield_outlined,
      order: 2,
    ),
    AcademyModule(
      id: 'stocks',
      title: 'Stocks & Variable Income',
      description: "What it means to be a part-owner of a company: price, market value, profit, dividends and volatility.",
      icon: Icons.trending_up,
      order: 3,
    ),
    AcademyModule(
      id: 'fundamental_analysis',
      title: 'Fundamental Analysis',
      description: 'P/E, P/B, ROE, margins and debt — tools for investigating a company, not buy signals.',
      icon: Icons.analytics_outlined,
      order: 4,
    ),
    AcademyModule(
      id: 'etfs',
      title: 'ETFs & Diversification',
      description: 'Exposure to dozens of companies at once: how index funds work.',
      icon: Icons.pie_chart_outline,
      order: 5,
    ),
    AcademyModule(
      id: 'crypto',
      title: 'Crypto Assets',
      description: 'Bitcoin, blockchain, and the specific risks of custody and volatility — responsibly explained.',
      icon: Icons.currency_bitcoin,
      order: 6,
    ),
    AcademyModule(
      id: 'portfolio_construction',
      title: 'Build Your Portfolio',
      description: 'Risk profile, time horizon and allocation across fixed income, stocks and ETFs.',
      icon: Icons.dashboard_customize_outlined,
      order: 7,
    ),
  ];

  static const List<AcademyModule> _modulesEs = [
    AcademyModule(
      id: 'investor_foundations',
      title: 'Fundamentos del Inversor',
      description: 'El lenguaje básico de invertir: ahorrar vs. invertir, patrimonio, inflación, interés compuesto, riesgo y diversificación.',
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
      title: 'Renta Fija',
      description: 'Cómo funcionan los CDB, el Tesoro Directo, LCI/LCA y los conceptos de liquidez, plazo y riesgo de crédito.',
      icon: Icons.shield_outlined,
      order: 2,
    ),
    AcademyModule(
      id: 'stocks',
      title: 'Acciones y Renta Variable',
      description: 'Qué significa ser socio de una empresa: precio, valor de mercado, ganancias, dividendos y volatilidad.',
      icon: Icons.trending_up,
      order: 3,
    ),
    AcademyModule(
      id: 'fundamental_analysis',
      title: 'Análisis Fundamental',
      description: 'P/E, P/VC, ROE, márgenes y endeudamiento — herramientas para investigar una empresa, no señales de compra.',
      icon: Icons.analytics_outlined,
      order: 4,
    ),
    AcademyModule(
      id: 'etfs',
      title: 'ETFs y Diversificación',
      description: 'Exposición a decenas de empresas a la vez: cómo funcionan los fondos indexados.',
      icon: Icons.pie_chart_outline,
      order: 5,
    ),
    AcademyModule(
      id: 'crypto',
      title: 'Criptoactivos',
      description: 'Bitcoin, blockchain y los riesgos específicos de custodia y volatilidad — con responsabilidad.',
      icon: Icons.currency_bitcoin,
      order: 6,
    ),
    AcademyModule(
      id: 'portfolio_construction',
      title: 'Arma tu Cartera',
      description: 'Perfil de riesgo, horizonte de tiempo y asignación entre renta fija, acciones y ETFs.',
      icon: Icons.dashboard_customize_outlined,
      order: 7,
    ),
  ];

  // ── Lessons — pt ──────────────────────────────────────────────────────

  static const List<Lesson> _lessonsPt = [
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

  // ── Lessons — en ──────────────────────────────────────────────────────

  static const List<Lesson> _lessonsEn = [
    Lesson(
      id: 'foundations_what_is_investing',
      moduleId: 'investor_foundations',
      title: 'What is Investing?',
      order: 1,
      xpReward: 20,
      steps: [
        ExplanationStep(
          title: 'Saving vs. Investing',
          body:
              "Investing is different from saving money. Saving means leaving money untouched; investing means "
              "putting that money to work to grow over time, accepting some risk in exchange for a potential "
              "return.",
        ),
        ExampleStep(
          title: 'In practice',
          body:
              "If you keep R\$100 under the mattress, in a year it's still R\$100. If you invest that R\$100 at a "
              "10% annual rate, you'll have R\$110.",
        ),
        ChoiceQuestionStep(
          framing: ChoiceStepFraming.microExercise,
          prompt: "What's the main difference between saving and investing?",
          options: [
            'Saving always earns more',
            'Investing involves taking on some risk in pursuit of a return',
            "There's no difference",
            'Saving is illegal in Brazil',
          ],
          correctIndex: 1,
          explanation:
              "That's right! Investing means accepting some degree of risk in the hope of a return greater than "
              "simply leaving money untouched.",
        ),
        ChoiceQuestionStep(
          framing: ChoiceStepFraming.apply,
          prompt: "You received extra money and won't need it for the next 5 years. What's worth investigating first?",
          options: [
            'Whichever investment promises the highest return, no further questions asked',
            "Your goals, time horizon, and how much risk you're willing to take",
            'Where your friends are investing',
            "Whatever investment is trending on social media",
          ],
          correctIndex: 1,
          explanation:
              "Before choosing where to invest, it's essential to understand your own goals, time horizon and risk "
              "tolerance — the right investment depends on you, not just the product.",
        ),
        SummaryStep(
          title: 'What you learned',
          takeaways: [
            'Saving means leaving money untouched; investing means trying to grow it.',
            'Investing involves accepting some risk in exchange for a potential return.',
            'Understanding your goals comes before choosing where to invest.',
          ],
        ),
      ],
    ),
    Lesson(
      id: 'foundations_assets_liabilities',
      moduleId: 'investor_foundations',
      title: 'Assets, Liabilities and Net Worth',
      order: 2,
      xpReward: 20,
      steps: [
        ExplanationStep(
          title: 'Two columns',
          body:
              'An asset is something that puts money in your pocket or has the potential to appreciate — like a '
              'stock or a rented property. A liability is something that takes money out of your pocket, like debt. '
              'Your net worth is the difference between everything you own (assets) and everything you owe '
              '(liabilities).',
        ),
        ExampleStep(
          title: 'In practice',
          body:
              'If you have R\$5,000 invested (an asset) and R\$2,000 in credit card debt (a liability), your net '
              'worth is R\$3,000.',
        ),
        ChoiceQuestionStep(
          framing: ChoiceStepFraming.microExercise,
          prompt: 'Which of the options below is a liability?',
          options: [
            'A stock you bought',
            'An outstanding car loan',
            'Money kept in a savings account',
            'A fully paid-off property',
          ],
          correctIndex: 1,
          explanation:
              "An outstanding loan takes money out of your pocket every month — that's why it's a liability.",
        ),
        ChoiceQuestionStep(
          framing: ChoiceStepFraming.apply,
          prompt:
              'Two people earn the same salary. One has a growing net worth; the other, a shrinking one. What most '
              'likely explains this difference?',
          options: [
            'Luck',
            'How each one manages the relationship between assets and liabilities over time',
            'Only the salary matters',
            "There's no possible explanation",
          ],
          correctIndex: 1,
          explanation:
              "Net worth doesn't just depend on how much you earn, but on how you balance what you own against "
              "what you owe, month after month.",
        ),
        SummaryStep(
          title: 'What you learned',
          takeaways: [
            'Assets put money in your pocket; liabilities take it out.',
            'Net worth = assets − liabilities.',
            'Tracking this equation over time is more revealing than looking at salary alone.',
          ],
        ),
      ],
    ),
    Lesson(
      id: 'foundations_inflation',
      moduleId: 'investor_foundations',
      title: 'Inflation and Purchasing Power',
      order: 3,
      xpReward: 20,
      steps: [
        ExplanationStep(
          title: 'What is inflation',
          body:
              "Inflation is the general rise in prices over time, which reduces the purchasing power of your "
              "money. If your income doesn't grow at least as fast as inflation, you can buy less and less with "
              "the same amount.",
        ),
        ExampleStep(
          title: 'In practice',
          body:
              'If a product cost R\$100 and inflation for the year was 5%, that same product now costs R\$105. If '
              'your idle money earned nothing, it now buys less than before.',
        ),
        ChoiceQuestionStep(
          framing: ChoiceStepFraming.microExercise,
          prompt:
              'If inflation for a year was 6% and your investment returned 4% in the same period, what happened to '
              'your purchasing power?',
          options: [
            'It increased',
            'It stayed the same',
            'It decreased, even with a positive return',
            "It's impossible to know",
          ],
          correctIndex: 2,
          explanation:
              "When the return falls below inflation, the so-called real return is negative — your money grew, "
              "but lost purchasing power.",
        ),
        ChoiceQuestionStep(
          framing: ChoiceStepFraming.apply,
          prompt:
              "You're choosing between leaving money in your checking account or investing in something that keeps "
              "pace with inflation. Why does this matter in the long run?",
          options: [
            "It doesn't matter, idle money never loses value",
            'Because, over the years, inflation erodes the real value of idle money',
            'Because inflation only affects large amounts',
            "Because it's purely a psychological issue",
          ],
          correctIndex: 1,
          explanation:
              'Over the years, even moderate inflation significantly reduces the purchasing power of money that '
              'sits idle without earning anything.',
        ),
        SummaryStep(
          title: 'What you learned',
          takeaways: [
            'Inflation reduces the purchasing power of money over time.',
            'Real return = return earned − inflation for the period.',
            'Leaving money idle has an invisible, but real, cost.',
          ],
        ),
      ],
    ),
    Lesson(
      id: 'foundations_compound_interest',
      moduleId: 'investor_foundations',
      title: 'Compound Interest',
      order: 4,
      xpReward: 20,
      steps: [
        ExplanationStep(
          title: 'Interest on interest',
          body:
              'Compound interest is calculated on the original amount plus interest already accumulated — you '
              'start earning interest on interest. This makes money grow at an accelerating pace, especially the '
              'longer it stays invested.',
        ),
        ExampleStep(
          title: 'In practice',
          body:
              'R\$1,000 invested at 10% a year becomes R\$1,100 after the first year. In the second year, the 10% '
              'applies to R\$1,100, not R\$1,000 anymore — resulting in R\$1,210.',
        ),
        ChoiceQuestionStep(
          framing: ChoiceStepFraming.microExercise,
          prompt: 'What most amplifies the effect of compound interest?',
          options: [
            'Investing once and forgetting about it',
            'The amount of time the money stays invested',
            'Switching investments frequently',
            'Only investing large amounts',
          ],
          correctIndex: 1,
          explanation:
              'Time is the most important ingredient of compound interest — the longer money stays invested, the '
              'greater the accumulated effect.',
        ),
        ChoiceQuestionStep(
          framing: ChoiceStepFraming.apply,
          prompt:
              'Two people invest the same monthly amount at the same rate. One starts at age 25, the other at 35. '
              'Why does the first one tend to end up with much more money, even investing the same total per '
              'month?',
          options: [
            'Because they had more luck',
            'Because their interest had more time to compound',
            'Because they invested in different assets',
            "There's no meaningful difference",
          ],
          correctIndex: 1,
          explanation:
              'Ten extra years of interest compounding on interest make a huge difference in the final result — '
              "that's the power of time combined with consistency.",
        ),
        SummaryStep(
          title: 'What you learned',
          takeaways: [
            'Compound interest is interest on interest already accumulated.',
            'Time invested is the most powerful factor in this effect.',
            'Starting early, even with little, tends to be worth more than starting late with more.',
          ],
        ),
      ],
    ),
    Lesson(
      id: 'foundations_risk_return',
      moduleId: 'investor_foundations',
      title: 'Risk and Return',
      order: 5,
      xpReward: 20,
      steps: [
        ExplanationStep(
          title: 'Two sides of the same coin',
          body:
              'Risk and return tend to go together: investments with higher potential returns generally carry a '
              "greater risk of fluctuation or loss. There's no guaranteed high return without some risk involved.",
        ),
        ExampleStep(
          title: 'In practice',
          body:
              "An investment that promises double the market's average return, with no apparent risk, should be "
              "investigated carefully — that balance usually doesn't exist.",
        ),
        ChoiceQuestionStep(
          framing: ChoiceStepFraming.microExercise,
          prompt: 'Is an investment with a higher expected return always the best choice?',
          options: [
            'Yes, the higher the return, the better',
            'No, because a higher return usually comes with more risk or less liquidity',
            "Yes, as long as it's currently trending",
            'No, because investments with higher returns are always scams',
          ],
          correctIndex: 1,
          explanation:
              "A higher return usually involves more risk, volatility, or less liquidity — the 'best' choice "
              "depends on your goal and risk tolerance, not just the number.",
        ),
        ChoiceQuestionStep(
          framing: ChoiceStepFraming.apply,
          prompt:
              'Liquidity is how easily an investment can be turned into available cash. Why does it matter '
              'alongside risk and return?',
          options: [
            "It isn't important",
            'Because an investment can have a good return but be hard to cash out exactly when you need the money',
            'Because liquidity always guarantees safety',
            'Because only liquid investments earn returns',
          ],
          correctIndex: 1,
          explanation:
              "Even a good investment might not work for you if the money is locked up exactly when you need it — "
              "liquidity is part of the equation.",
        ),
        SummaryStep(
          title: 'What you learned',
          takeaways: [
            'Risk and return tend to be related.',
            "A higher return isn't automatically 'better' — it depends on your context.",
            'Liquidity matters too: consider when you might need the money back.',
          ],
        ),
      ],
    ),
    Lesson(
      id: 'foundations_diversification',
      moduleId: 'investor_foundations',
      title: 'Diversification',
      order: 6,
      xpReward: 20,
      steps: [
        ExplanationStep(
          title: "Don't put it all in one place",
          body:
              'Diversifying means spreading your investments across different assets, sectors or types of '
              'investment, instead of concentrating everything in one place. The goal is not to eliminate risk, but '
              'to reduce the impact of any single investment going badly.',
        ),
        ExampleStep(
          title: 'In practice',
          body:
              "If you invest everything in a single company and it runs into trouble, your entire net worth "
              "suffers. If you spread it across several companies and asset types, the impact of an isolated "
              "problem tends to be smaller.",
        ),
        ChoiceQuestionStep(
          framing: ChoiceStepFraming.microExercise,
          prompt: 'What is the main goal of diversification?',
          options: [
            "Guaranteeing you'll never have a loss",
            'Reducing the impact of one specific investment going badly on the portfolio as a whole',
            'Guaranteeing higher returns',
            'Simplifying the portfolio as much as possible',
          ],
          correctIndex: 1,
          explanation:
              "Diversifying doesn't eliminate risk or guarantee profit — it helps reduce the impact of an isolated "
              "problem on the portfolio as a whole.",
        ),
        ChoiceQuestionStep(
          framing: ChoiceStepFraming.apply,
          prompt:
              'You already understand saving vs. investing, net worth, inflation and risk. How does that help you '
              'think about diversification?',
          options: [
            'By choosing only whatever asset seems trendy right now',
            'By considering how different types of investment can behave differently facing the same scenario',
            'It makes no difference, all assets behave the same',
            'Diversification only exists for large investors',
          ],
          correctIndex: 1,
          explanation:
              "Different assets react differently to the same economic events — it's exactly that difference that "
              "makes diversification useful.",
        ),
        SummaryStep(
          title: 'Module complete!',
          takeaways: [
            'Diversifying is spreading investments across different assets and categories.',
            'The goal is to reduce the impact of an isolated problem, not eliminate risk.',
            'You now have the foundation to start exploring fixed income and stocks.',
          ],
        ),
      ],
    ),
  ];

  // ── Lessons — es ──────────────────────────────────────────────────────

  static const List<Lesson> _lessonsEs = [
    Lesson(
      id: 'foundations_what_is_investing',
      moduleId: 'investor_foundations',
      title: '¿Qué es Invertir?',
      order: 1,
      xpReward: 20,
      steps: [
        ExplanationStep(
          title: 'Ahorrar vs. Invertir',
          body:
              'Invertir es diferente de ahorrar dinero. Ahorrar es dejar el dinero quieto; invertir es hacer que '
              'ese dinero trabaje para crecer con el tiempo, aceptando algún riesgo a cambio de un retorno '
              'potencial.',
        ),
        ExampleStep(
          title: 'En la práctica',
          body:
              'Si guardas R\$100 debajo del colchón, dentro de un año seguirán siendo R\$100. Si inviertes esos '
              'R\$100 a una tasa del 10% anual, tendrás R\$110.',
        ),
        ChoiceQuestionStep(
          framing: ChoiceStepFraming.microExercise,
          prompt: '¿Cuál es la principal diferencia entre ahorrar e invertir?',
          options: [
            'Ahorrar siempre rinde más',
            'Invertir implica asumir algún riesgo en busca de un retorno',
            'No hay diferencia',
            'Ahorrar está prohibido en Brasil',
          ],
          correctIndex: 1,
          explanation:
              '¡Exacto! Invertir significa aceptar cierto grado de riesgo con la expectativa de un retorno mayor '
              'que simplemente dejar el dinero quieto.',
        ),
        ChoiceQuestionStep(
          framing: ChoiceStepFraming.apply,
          prompt:
              'Recibiste un dinero extra y no lo necesitarás en los próximos 5 años. ¿Qué tiene más sentido '
              'investigar primero?',
          options: [
            'Qué inversión promete el mayor retorno, sin más preguntas',
            'Tus objetivos, plazo y cuánto riesgo estás dispuesto a asumir',
            'Dónde están invirtiendo tus amigos',
            'Qué inversión está de moda en redes sociales',
          ],
          correctIndex: 1,
          explanation:
              'Antes de elegir dónde invertir, es esencial entender tus propios objetivos, plazo y tolerancia al '
              'riesgo — la inversión correcta depende de ti, no solo del producto.',
        ),
        SummaryStep(
          title: 'Lo que aprendiste',
          takeaways: [
            'Ahorrar es dejar el dinero quieto; invertir es buscar hacerlo crecer.',
            'Invertir implica aceptar algún riesgo a cambio de un retorno potencial.',
            'Entender tus objetivos viene antes de elegir dónde invertir.',
          ],
        ),
      ],
    ),
    Lesson(
      id: 'foundations_assets_liabilities',
      moduleId: 'investor_foundations',
      title: 'Activos, Pasivos y Patrimonio',
      order: 2,
      xpReward: 20,
      steps: [
        ExplanationStep(
          title: 'Dos columnas',
          body:
              'Un activo es algo que pone dinero en tu bolsillo o tiene potencial de valorizarse — como una acción '
              'o un inmueble alquilado. Un pasivo es algo que saca dinero de tu bolsillo, como una deuda. Tu '
              'patrimonio neto es la diferencia entre todo lo que posees (activos) y todo lo que debes (pasivos).',
        ),
        ExampleStep(
          title: 'En la práctica',
          body:
              'Si tienes R\$5.000 invertidos (activo) y R\$2.000 de deuda en la tarjeta de crédito (pasivo), tu '
              'patrimonio neto es R\$3.000.',
        ),
        ChoiceQuestionStep(
          framing: ChoiceStepFraming.microExercise,
          prompt: '¿Cuál de las siguientes opciones es un pasivo?',
          options: [
            'Una acción que compraste',
            'Un préstamo de auto pendiente',
            'Dinero guardado en una cuenta de ahorros',
            'Un inmueble totalmente pagado',
          ],
          correctIndex: 1,
          explanation: 'Un préstamo pendiente saca dinero de tu bolsillo cada mes — por eso es un pasivo.',
        ),
        ChoiceQuestionStep(
          framing: ChoiceStepFraming.apply,
          prompt:
              'Dos personas ganan el mismo salario. Una tiene un patrimonio neto creciente; la otra, decreciente. '
              '¿Qué explica probablemente esta diferencia?',
          options: [
            'La suerte',
            'Cómo cada una administra la relación entre activos y pasivos a lo largo del tiempo',
            'Solo importa el salario',
            'No hay explicación posible',
          ],
          correctIndex: 1,
          explanation:
              'El patrimonio no depende solo de cuánto ganas, sino de cómo equilibras lo que posees con lo que '
              'debes, mes tras mes.',
        ),
        SummaryStep(
          title: 'Lo que aprendiste',
          takeaways: [
            'Los activos ponen dinero en tu bolsillo; los pasivos lo sacan.',
            'Patrimonio neto = activos − pasivos.',
            'Seguir esta ecuación con el tiempo revela más que mirar solo el salario.',
          ],
        ),
      ],
    ),
    Lesson(
      id: 'foundations_inflation',
      moduleId: 'investor_foundations',
      title: 'Inflación y Poder Adquisitivo',
      order: 3,
      xpReward: 20,
      steps: [
        ExplanationStep(
          title: 'Qué es la inflación',
          body:
              'La inflación es el aumento general de los precios a lo largo del tiempo, que reduce el poder de '
              'compra de tu dinero. Si tus ingresos no crecen al menos al mismo ritmo, puedes comprar cada vez '
              'menos con el mismo valor.',
        ),
        ExampleStep(
          title: 'En la práctica',
          body:
              'Si un producto costaba R\$100 y la inflación del año fue del 5%, ese mismo producto ahora cuesta '
              'R\$105. Si tu dinero parado no rindió nada, ahora compra menos que antes.',
        ),
        ChoiceQuestionStep(
          framing: ChoiceStepFraming.microExercise,
          prompt:
              'Si la inflación de un año fue del 6% y tu inversión rindió el 4% en el mismo período, ¿qué pasó con '
              'tu poder de compra?',
          options: [
            'Aumentó',
            'Se mantuvo igual',
            'Disminuyó, aunque el retorno fue positivo',
            'Es imposible saberlo',
          ],
          correctIndex: 2,
          explanation:
              'Cuando el retorno queda por debajo de la inflación, el llamado retorno real es negativo — tu dinero '
              'rindió, pero perdió poder de compra.',
        ),
        ChoiceQuestionStep(
          framing: ChoiceStepFraming.apply,
          prompt:
              'Estás eligiendo entre dejar el dinero en la cuenta corriente o invertir en algo que siga el ritmo '
              'de la inflación. ¿Por qué importa esto a largo plazo?',
          options: [
            'No importa, el dinero parado nunca pierde valor',
            'Porque, con los años, la inflación erosiona el valor real del dinero parado',
            'Porque la inflación solo afecta a grandes cantidades',
            'Porque es solo una cuestión psicológica',
          ],
          correctIndex: 1,
          explanation:
              'Con los años, incluso una inflación moderada reduce bastante el poder de compra del dinero que '
              'queda parado sin rendir.',
        ),
        SummaryStep(
          title: 'Lo que aprendiste',
          takeaways: [
            'La inflación reduce el poder de compra del dinero con el tiempo.',
            'Retorno real = retorno obtenido − inflación del período.',
            'Dejar el dinero parado tiene un costo invisible, pero real.',
          ],
        ),
      ],
    ),
    Lesson(
      id: 'foundations_compound_interest',
      moduleId: 'investor_foundations',
      title: 'Interés Compuesto',
      order: 4,
      xpReward: 20,
      steps: [
        ExplanationStep(
          title: 'Interés sobre interés',
          body:
              'El interés compuesto se calcula sobre el monto original más los intereses ya acumulados — empiezas '
              'a ganar intereses sobre intereses. Esto hace que el dinero crezca de forma acelerada, especialmente '
              'cuanto más tiempo permanezca invertido.',
        ),
        ExampleStep(
          title: 'En la práctica',
          body:
              'R\$1.000 invertidos al 10% anual se convierten en R\$1.100 después del primer año. En el segundo '
              'año, el 10% se aplica sobre R\$1.100, ya no sobre R\$1.000 — dando como resultado R\$1.210.',
        ),
        ChoiceQuestionStep(
          framing: ChoiceStepFraming.microExercise,
          prompt: '¿Qué potencia más el efecto del interés compuesto?',
          options: [
            'Invertir una sola vez y olvidarse',
            'El tiempo que el dinero permanece invertido',
            'Cambiar de inversión con frecuencia',
            'Invertir solo grandes cantidades',
          ],
          correctIndex: 1,
          explanation:
              'El tiempo es el ingrediente más importante del interés compuesto — cuanto más tiempo el dinero '
              'permanece invertido, mayor es el efecto acumulado.',
        ),
        ChoiceQuestionStep(
          framing: ChoiceStepFraming.apply,
          prompt:
              'Dos personas invierten el mismo monto mensual, a la misma tasa. Una empieza a los 25 años, la otra '
              'a los 35. ¿Por qué la primera tiende a terminar con mucho más dinero, incluso invirtiendo el mismo '
              'total mensual?',
          options: [
            'Porque tuvo más suerte',
            'Porque sus intereses tuvieron más tiempo para componerse',
            'Porque invirtió en activos diferentes',
            'No hay una diferencia relevante',
          ],
          correctIndex: 1,
          explanation:
              'Diez años más de intereses componiéndose sobre intereses generan una diferencia enorme en el '
              'resultado final — ese es el poder del tiempo combinado con la constancia.',
        ),
        SummaryStep(
          title: 'Lo que aprendiste',
          takeaways: [
            'El interés compuesto es interés sobre intereses ya acumulados.',
            'El tiempo invertido es el factor más poderoso de este efecto.',
            'Empezar temprano, aunque sea con poco, suele valer más que empezar tarde con más.',
          ],
        ),
      ],
    ),
    Lesson(
      id: 'foundations_risk_return',
      moduleId: 'investor_foundations',
      title: 'Riesgo y Retorno',
      order: 5,
      xpReward: 20,
      steps: [
        ExplanationStep(
          title: 'Dos caras de la misma moneda',
          body:
              'Riesgo y retorno suelen ir de la mano: las inversiones con mayor potencial de retorno generalmente '
              'implican mayor riesgo de oscilación o pérdida. No existe un retorno alto garantizado sin algún '
              'riesgo involucrado.',
        ),
        ExampleStep(
          title: 'En la práctica',
          body:
              'Una inversión que promete el doble del retorno promedio del mercado, sin ningún riesgo aparente, '
              'debe investigarse con cautela — ese equilibrio normalmente no existe.',
        ),
        ChoiceQuestionStep(
          framing: ChoiceStepFraming.microExercise,
          prompt: '¿Una inversión con retorno esperado más alto es siempre la mejor opción?',
          options: [
            'Sí, cuanto mayor el retorno, mejor',
            'No, porque el retorno más alto suele venir acompañado de más riesgo o menos liquidez',
            'Sí, siempre que esté de moda en el momento',
            'No, porque las inversiones con mayor retorno siempre son estafas',
          ],
          correctIndex: 1,
          explanation:
              "Un retorno mayor normalmente implica más riesgo, volatilidad o menos liquidez — la 'mejor' opción "
              'depende de tu objetivo y tolerancia al riesgo, no solo del número.',
        ),
        ChoiceQuestionStep(
          framing: ChoiceStepFraming.apply,
          prompt:
              'La liquidez es la facilidad de convertir una inversión en dinero disponible. ¿Por qué importa junto '
              'al riesgo y el retorno?',
          options: [
            'No es importante',
            'Porque una inversión puede tener buen retorno, pero ser difícil de rescatar justo cuando necesitas el dinero',
            'Porque la liquidez siempre garantiza seguridad',
            'Porque solo las inversiones líquidas rinden',
          ],
          correctIndex: 1,
          explanation:
              'Incluso una buena inversión puede no servirte si el dinero queda atrapado justo cuando lo '
              'necesitas — la liquidez es parte de la ecuación.',
        ),
        SummaryStep(
          title: 'Lo que aprendiste',
          takeaways: [
            'Riesgo y retorno suelen estar relacionados.',
            "Un retorno más alto no es automáticamente 'mejor' — depende de tu contexto.",
            'La liquidez también importa: considera cuándo podrías necesitar el dinero de vuelta.',
          ],
        ),
      ],
    ),
    Lesson(
      id: 'foundations_diversification',
      moduleId: 'investor_foundations',
      title: 'Diversificación',
      order: 6,
      xpReward: 20,
      steps: [
        ExplanationStep(
          title: 'No pongas todo en el mismo lugar',
          body:
              'Diversificar significa distribuir tus inversiones entre diferentes activos, sectores o tipos de '
              'inversión, en lugar de concentrar todo en un solo lugar. El objetivo no es eliminar el riesgo, sino '
              'reducir el impacto de que una sola inversión vaya mal.',
        ),
        ExampleStep(
          title: 'En la práctica',
          body:
              'Si inviertes todo en una sola empresa y esta enfrenta dificultades, todo tu patrimonio sufre. Si lo '
              'distribuyes entre varias empresas y tipos de activos, el impacto de un problema aislado tiende a ser '
              'menor.',
        ),
        ChoiceQuestionStep(
          framing: ChoiceStepFraming.microExercise,
          prompt: '¿Cuál es el principal objetivo de la diversificación?',
          options: [
            'Garantizar que nunca tendrás pérdidas',
            'Reducir el impacto de que una inversión específica vaya mal sobre el total de la cartera',
            'Garantizar un mayor retorno',
            'Simplificar la cartera al máximo',
          ],
          correctIndex: 1,
          explanation:
              'Diversificar no elimina el riesgo ni garantiza ganancias — ayuda a reducir el impacto de un '
              'problema aislado sobre el conjunto de la cartera.',
        ),
        ChoiceQuestionStep(
          framing: ChoiceStepFraming.apply,
          prompt:
              'Ya entiendes ahorrar vs. invertir, patrimonio, inflación y riesgo. ¿Cómo te ayuda esto a pensar en '
              'la diversificación?',
          options: [
            'Eligiendo solo el activo que parece estar de moda en el momento',
            'Considerando cómo diferentes tipos de inversión pueden comportarse de forma distinta ante el mismo escenario',
            'No hace diferencia, todos los activos se comportan igual',
            'La diversificación solo existe para grandes inversores',
          ],
          correctIndex: 1,
          explanation:
              'Activos diferentes reaccionan de forma distinta ante los mismos eventos económicos — es justamente '
              'esa diferencia la que hace útil la diversificación.',
        ),
        SummaryStep(
          title: '¡Módulo completado!',
          takeaways: [
            'Diversificar es distribuir inversiones entre diferentes activos y categorías.',
            'El objetivo es reducir el impacto de un problema aislado, no eliminar el riesgo.',
            'Ya tienes la base para empezar a explorar la renta fija y las acciones.',
          ],
        ),
      ],
    ),
  ];
}
