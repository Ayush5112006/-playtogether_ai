import 'dart:math';

class Option {
  final String id; // "A", "B", "C", "D"
  final String text;

  Option({required this.id, required this.text});

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      id: json['id'] as String? ?? 'A',
      text: json['text'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
      };
}

class Question {
  final String id;
  final String category;
  final String categoryEmoji;
  final String difficulty; // "EASY", "MEDIUM", "HARD"
  final String questionText;
  final String quoteHighlight;
  final List<Option> options;
  final String correctOptionId;
  final String explanation;
  final int pointValue;

  Question({
    required this.id,
    required this.category,
    this.categoryEmoji = '🧠',
    required this.difficulty,
    required this.questionText,
    this.quoteHighlight = '',
    required this.options,
    required this.correctOptionId,
    required this.explanation,
    required this.pointValue,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    var rawOptions = json['options'] as List<dynamic>? ?? [];
    List<Option> opts = rawOptions.map((o) => Option.fromJson(o as Map<String, dynamic>)).toList();

    return Question(
      id: json['id'] as String? ?? 'q_001',
      category: json['category'] as String? ?? 'General',
      categoryEmoji: json['categoryEmoji'] as String? ?? json['category_emoji'] as String? ?? '🧠',
      difficulty: json['difficulty'] as String? ?? 'MEDIUM',
      questionText: json['question'] as String? ?? json['questionText'] as String? ?? '',
      quoteHighlight: json['quoteHighlight'] as String? ?? json['quote_highlight'] as String? ?? '',
      options: opts,
      correctOptionId: json['correctOptionId'] as String? ?? json['correct_option_id'] as String? ?? 'A',
      explanation: json['explanation'] as String? ?? '',
      pointValue: json['pointValue'] as int? ?? json['point_value'] as int? ?? 100,
    );
  }

  int get correctIndex {
    final idx = options.indexWhere((o) => o.id == correctOptionId);
    return idx != -1 ? idx : 0;
  }

  int get points => pointValue;

  /// Shuffles questions randomly on every call, with optional category/difficulty filters
  static List<Question> getShuffledQuestions({
    String? category,
    String? difficulty,
    int limit = 10,
  }) {
    final all = List<Question>.from(getSampleQuestions());
    final rand = Random();

    List<Question> matching = [];

    if (category != null && category.isNotEmpty && category.toLowerCase() != 'all' && category.toLowerCase() != 'mixed') {
      final catLower = category.toLowerCase().trim();
      matching = all.where((q) {
        final qCat = q.category.toLowerCase().trim();
        return qCat.contains(catLower) || catLower.contains(qCat);
      }).toList();
    }

    if (matching.isEmpty) {
      matching = List<Question>.from(all);
    }

    if (difficulty != null && difficulty.isNotEmpty && difficulty != 'ADAPTIVE') {
      final diffMatch = matching.where((q) => q.difficulty.toUpperCase() == difficulty.toUpperCase()).toList();
      if (diffMatch.length >= limit) {
        matching = diffMatch;
      }
    }

    matching.shuffle(rand);

    if (matching.length < limit) {
      final remaining = all.where((q) => !matching.any((m) => m.id == q.id)).toList()..shuffle(rand);
      matching.addAll(remaining);
    }

    return matching.take(limit).toList();
  }

  static List<Question> getSampleQuestions() {
    return [
      // --- CINEMA CLUES ---
      Question(
        id: 'q_001',
        category: 'Cinema Clues',
        categoryEmoji: '🎬',
        difficulty: 'MEDIUM',
        questionText: 'Which movie character is famous for the line:',
        quoteHighlight: '"May the Force be with you"',
        options: [
          Option(id: 'A', text: 'Luke Skywalker'),
          Option(id: 'B', text: 'Han Solo'),
          Option(id: 'C', text: 'Obi-Wan Kenobi'),
          Option(id: 'D', text: 'Darth Vader'),
        ],
        correctOptionId: 'B',
        explanation: 'Han Solo says "May the Force be with you" to Luke before the assault on the Death Star.',
        pointValue: 150,
      ),
      Question(
        id: 'q_002',
        category: 'Cinema Clues',
        categoryEmoji: '🎬',
        difficulty: 'EASY',
        questionText: 'In The Wizard of Oz, what color brick road must Dorothy follow to reach Emerald City?',
        quoteHighlight: '"Follow the road to the Emerald City"',
        options: [
          Option(id: 'A', text: 'Yellow'),
          Option(id: 'B', text: 'Red'),
          Option(id: 'C', text: 'Blue'),
          Option(id: 'D', text: 'Gold'),
        ],
        correctOptionId: 'A',
        explanation: 'Dorothy must follow the Yellow Brick Road to find the Wizard in the Emerald City.',
        pointValue: 100,
      ),
      Question(
        id: 'q_003',
        category: 'Cinema Clues',
        categoryEmoji: '🎬',
        difficulty: 'MEDIUM',
        questionText: 'Who directed the landmark 1993 cinematic dinosaur thriller Jurassic Park?',
        quoteHighlight: '"Life finds a way"',
        options: [
          Option(id: 'A', text: 'James Cameron'),
          Option(id: 'B', text: 'Steven Spielberg'),
          Option(id: 'C', text: 'George Lucas'),
          Option(id: 'D', text: 'Ridley Scott'),
        ],
        correctOptionId: 'B',
        explanation: 'Steven Spielberg directed Jurassic Park, which revolutionized visual effects in cinema.',
        pointValue: 150,
      ),
      Question(
        id: 'q_004',
        category: 'Cinema Clues',
        categoryEmoji: '🎬',
        difficulty: 'HARD',
        questionText: 'In Christopher Nolan\'s Inception, what object does Dom Cobb use as his personal totem?',
        quoteHighlight: '"An unmistakable check on reality"',
        options: [
          Option(id: 'A', text: 'A chess pawn'),
          Option(id: 'B', text: 'A spinning top'),
          Option(id: 'C', text: 'A loaded die'),
          Option(id: 'D', text: 'A bronze coin'),
        ],
        correctOptionId: 'B',
        explanation: 'Cobb uses a small brass spinning top originally belonging to his wife Mal to test if he is dreaming.',
        pointValue: 200,
      ),
      Question(
        id: 'q_005',
        category: 'Cinema Clues',
        categoryEmoji: '🎬',
        difficulty: 'HARD',
        questionText: 'Which was the first animated feature film ever nominated for the Academy Award for Best Picture?',
        quoteHighlight: '"Tale as old as time"',
        options: [
          Option(id: 'A', text: 'The Lion King'),
          Option(id: 'B', text: 'Snow White and the Seven Dwarfs'),
          Option(id: 'C', text: 'Beauty and the Beast'),
          Option(id: 'D', text: 'Toy Story'),
        ],
        correctOptionId: 'C',
        explanation: 'Beauty and the Beast (1991) made history as the very first animated film nominated for Best Picture.',
        pointValue: 200,
      ),
      Question(
        id: 'q_006',
        category: 'Cinema Clues',
        categoryEmoji: '🎬',
        difficulty: 'EASY',
        questionText: 'Which superhero is the secret identity of billionaire Bruce Wayne?',
        quoteHighlight: '"The Dark Knight of Gotham City"',
        options: [
          Option(id: 'A', text: 'Iron Man'),
          Option(id: 'B', text: 'Spider-Man'),
          Option(id: 'C', text: 'Batman'),
          Option(id: 'D', text: 'Superman'),
        ],
        correctOptionId: 'C',
        explanation: 'Bruce Wayne patrols Gotham City under the mantle of Batman.',
        pointValue: 100,
      ),
      Question(
        id: 'q_007',
        category: 'Cinema Clues',
        categoryEmoji: '🎬',
        difficulty: 'MEDIUM',
        questionText: 'What fictional metal coats Wolverine\'s skeleton and retractable claws?',
        quoteHighlight: '"Indestructible rare metal alloy"',
        options: [
          Option(id: 'A', text: 'Vibranium'),
          Option(id: 'B', text: 'Mithril'),
          Option(id: 'C', text: 'Adamantium'),
          Option(id: 'D', text: 'Beskar'),
        ],
        correctOptionId: 'C',
        explanation: 'Wolverine\'s bones and claws are bonded with the indestructible fictional metal Adamantium.',
        pointValue: 150,
      ),

      // --- SCIENCE & COSMOS ---
      Question(
        id: 'q_008',
        category: 'Science & Cosmos',
        categoryEmoji: '🚀',
        difficulty: 'MEDIUM',
        questionText: 'Which planet in our solar system has the highest surface temperature?',
        quoteHighlight: '"Surface temperature exceeds 860°F"',
        options: [
          Option(id: 'A', text: 'Mercury'),
          Option(id: 'B', text: 'Venus'),
          Option(id: 'C', text: 'Mars'),
          Option(id: 'D', text: 'Jupiter'),
        ],
        correctOptionId: 'B',
        explanation: 'Venus is hotter than Mercury due to an intense runaway greenhouse effect from dense carbon dioxide.',
        pointValue: 150,
      ),
      Question(
        id: 'q_009',
        category: 'Science & Cosmos',
        categoryEmoji: '🚀',
        difficulty: 'EASY',
        questionText: 'What is the closest star to planet Earth?',
        quoteHighlight: '"Center of our solar system"',
        options: [
          Option(id: 'A', text: 'Proxima Centauri'),
          Option(id: 'B', text: 'Betelgeuse'),
          Option(id: 'C', text: 'The Sun'),
          Option(id: 'D', text: 'Sirius'),
        ],
        correctOptionId: 'C',
        explanation: 'The Sun is our home star, located roughly 93 million miles from Earth.',
        pointValue: 100,
      ),
      Question(
        id: 'q_010',
        category: 'Science & Cosmos',
        categoryEmoji: '🚀',
        difficulty: 'MEDIUM',
        questionText: 'What is the most abundant gas in Earth\'s atmosphere?',
        quoteHighlight: '"Comprises roughly 78% of the air we breathe"',
        options: [
          Option(id: 'A', text: 'Oxygen'),
          Option(id: 'B', text: 'Nitrogen'),
          Option(id: 'C', text: 'Carbon Dioxide'),
          Option(id: 'D', text: 'Argon'),
        ],
        correctOptionId: 'B',
        explanation: 'Nitrogen makes up approximately 78% of Earth\'s atmosphere, while oxygen makes up about 21%.',
        pointValue: 150,
      ),
      Question(
        id: 'q_011',
        category: 'Science & Cosmos',
        categoryEmoji: '🚀',
        difficulty: 'HARD',
        questionText: 'How many minutes does it take light emitted from the Sun to reach Earth?',
        quoteHighlight: '"Traveling across 93 million miles of vacuum"',
        options: [
          Option(id: 'A', text: 'Approx. 1 minute'),
          Option(id: 'B', text: 'Approx. 4.5 minutes'),
          Option(id: 'C', text: 'Approx. 8.3 minutes'),
          Option(id: 'D', text: 'Approx. 15 minutes'),
        ],
        correctOptionId: 'C',
        explanation: 'Light travels at 300,000 km/s and requires roughly 8 minutes and 20 seconds to reach Earth.',
        pointValue: 200,
      ),
      Question(
        id: 'q_012',
        category: 'Science & Cosmos',
        categoryEmoji: '🚀',
        difficulty: 'EASY',
        questionText: 'What is the chemical symbol for the element Gold on the Periodic Table?',
        quoteHighlight: '"Derived from the Latin word Aurum"',
        options: [
          Option(id: 'A', text: 'Ag'),
          Option(id: 'B', text: 'Au'),
          Option(id: 'C', text: 'Fe'),
          Option(id: 'D', text: 'Gd'),
        ],
        correctOptionId: 'B',
        explanation: 'Au comes from the Latin word Aurum, meaning glowing dawn.',
        pointValue: 100,
      ),
      Question(
        id: 'q_013',
        category: 'Science & Cosmos',
        categoryEmoji: '🚀',
        difficulty: 'MEDIUM',
        questionText: 'Which organ in the human body consumes roughly 20% of its total resting energy?',
        quoteHighlight: '"The central command center"',
        options: [
          Option(id: 'A', text: 'Heart'),
          Option(id: 'B', text: 'Liver'),
          Option(id: 'C', text: 'Brain'),
          Option(id: 'D', text: 'Lungs'),
        ],
        correctOptionId: 'C',
        explanation: 'Despite accounting for only 2% of body weight, the human brain consumes about 20% of resting metabolic energy.',
        pointValue: 150,
      ),
      Question(
        id: 'q_014',
        category: 'Science & Cosmos',
        categoryEmoji: '🚀',
        difficulty: 'HARD',
        questionText: 'Which fundamental subatomic particle carries no electric charge?',
        quoteHighlight: '"Located alongside protons in the atomic nucleus"',
        options: [
          Option(id: 'A', text: 'Electron'),
          Option(id: 'B', text: 'Positron'),
          Option(id: 'C', text: 'Neutron'),
          Option(id: 'D', text: 'Muon'),
        ],
        correctOptionId: 'C',
        explanation: 'Neutrons are electrically neutral subatomic particles residing in the nucleus.',
        pointValue: 200,
      ),

      // --- POP CULTURE & MUSIC ---
      Question(
        id: 'q_015',
        category: 'Pop Culture & Music',
        categoryEmoji: '🎵',
        difficulty: 'EASY',
        questionText: 'Which famous band performed an impromptu concert on the roof of Apple Records in 1969?',
        quoteHighlight: '"Get Back to where you once belonged"',
        options: [
          Option(id: 'A', text: 'The Rolling Stones'),
          Option(id: 'B', text: 'The Beatles'),
          Option(id: 'C', text: 'Queen'),
          Option(id: 'D', text: 'Led Zeppelin'),
        ],
        correctOptionId: 'B',
        explanation: 'The Beatles gave their final public rooftop performance at their London headquarters in January 1969.',
        pointValue: 100,
      ),
      Question(
        id: 'q_016',
        category: 'Pop Culture & Music',
        categoryEmoji: '🎵',
        difficulty: 'MEDIUM',
        questionText: 'Which artist released the all-time best-selling studio album Thriller in 1982?',
        quoteHighlight: '"Cause this is thriller, thriller night"',
        options: [
          Option(id: 'A', text: 'Prince'),
          Option(id: 'B', text: 'Stevie Wonder'),
          Option(id: 'C', text: 'Michael Jackson'),
          Option(id: 'D', text: 'Lionel Richie'),
        ],
        correctOptionId: 'C',
        explanation: 'Michael Jackson\'s Thriller became the best-selling album of all time worldwide.',
        pointValue: 150,
      ),
      Question(
        id: 'q_017',
        category: 'Pop Culture & Music',
        categoryEmoji: '🎵',
        difficulty: 'EASY',
        questionText: 'What was Elvis Presley widely celebrated as in musical history?',
        quoteHighlight: '"Hail to the pioneer of rock n roll"',
        options: [
          Option(id: 'A', text: 'The Duke'),
          Option(id: 'B', text: 'The Boss'),
          Option(id: 'C', text: 'The King'),
          Option(id: 'D', text: 'The Prince'),
        ],
        correctOptionId: 'C',
        explanation: 'Elvis Presley is globally known as "The King of Rock and Roll".',
        pointValue: 100,
      ),
      Question(
        id: 'q_018',
        category: 'Pop Culture & Music',
        categoryEmoji: '🎵',
        difficulty: 'HARD',
        questionText: 'In what year did the legendary original Woodstock Music & Art Fair take place?',
        quoteHighlight: '"3 Days of Peace & Music"',
        options: [
          Option(id: 'A', text: '1967'),
          Option(id: 'B', text: '1969'),
          Option(id: 'C', text: '1971'),
          Option(id: 'D', text: '1973'),
        ],
        correctOptionId: 'B',
        explanation: 'The historic Woodstock festival took place in August 1969 on Max Yasgur\'s dairy farm in Bethel, New York.',
        pointValue: 200,
      ),
      Question(
        id: 'q_019',
        category: 'Pop Culture & Music',
        categoryEmoji: '🎵',
        difficulty: 'MEDIUM',
        questionText: 'Who is the legendary Nintendo game designer who created Super Mario, Donkey Kong, and Zelda?',
        quoteHighlight: '"Father of modern interactive gaming"',
        options: [
          Option(id: 'A', text: 'Hideo Kojima'),
          Option(id: 'B', text: 'Shigeru Miyamoto'),
          Option(id: 'C', text: 'Satoru Iwata'),
          Option(id: 'D', text: 'Masahiro Sakurai'),
        ],
        correctOptionId: 'B',
        explanation: 'Shigeru Miyamoto is the celebrated visionary behind many of Nintendo\'s most iconic franchises.',
        pointValue: 150,
      ),

      // --- ANIMATION & FAMILY ---
      Question(
        id: 'q_020',
        category: 'Animation & Family',
        categoryEmoji: '✨',
        difficulty: 'EASY',
        questionText: 'In Disney\'s Toy Story, what is the name of Woody and Andy\'s real pet Dachshund?',
        quoteHighlight: '"You\'ve got a friend in me"',
        options: [
          Option(id: 'A', text: 'Slinky'),
          Option(id: 'B', text: 'Buster'),
          Option(id: 'C', text: 'Rex'),
          Option(id: 'D', text: 'Scud'),
        ],
        correctOptionId: 'B',
        explanation: 'Buster is Andy\'s pet Dachshund who listens to Woody\'s commands.',
        pointValue: 100,
      ),
      Question(
        id: 'q_021',
        category: 'Animation & Family',
        categoryEmoji: '✨',
        difficulty: 'MEDIUM',
        questionText: 'In Pixar\'s Finding Nemo, what address in Sydney is written on the diver\'s scuba mask?',
        quoteHighlight: '"P. Sherman, 42 Wallaby Way..."',
        options: [
          Option(id: 'A', text: '42 Wallaby Way, Sydney'),
          Option(id: 'B', text: '12 Ocean Boulevard, Sydney'),
          Option(id: 'C', text: '24 Coral Reef Drive, Sydney'),
          Option(id: 'D', text: '88 Harbour Bridge Way, Sydney'),
        ],
        correctOptionId: 'A',
        explanation: 'Dory famously memorizes the dentist\'s address: "P. Sherman, 42 Wallaby Way, Sydney".',
        pointValue: 150,
      ),
      Question(
        id: 'q_022',
        category: 'Animation & Family',
        categoryEmoji: '✨',
        difficulty: 'EASY',
        questionText: 'In Disney\'s The Lion King, what does the memorable phrase "Hakuna Matata" mean?',
        quoteHighlight: '"No worries for the rest of your days"',
        options: [
          Option(id: 'A', text: 'Be brave always'),
          Option(id: 'B', text: 'No worries'),
          Option(id: 'C', text: 'Family first'),
          Option(id: 'D', text: 'Circle of life'),
        ],
        correctOptionId: 'B',
        explanation: 'Timon and Pumbaa teach Simba that Hakuna Matata is a Swahili phrase meaning "no worries".',
        pointValue: 100,
      ),
      Question(
        id: 'q_023',
        category: 'Animation & Family',
        categoryEmoji: '✨',
        difficulty: 'MEDIUM',
        questionText: 'What is the name of the superhero family\'s multi-powered baby in The Incredibles?',
        quoteHighlight: '"A baby bursting with super abilities"',
        options: [
          Option(id: 'A', text: 'Dash'),
          Option(id: 'B', text: 'Jack-Jack'),
          Option(id: 'C', text: 'Buddy'),
          Option(id: 'D', text: 'Bob Jr.'),
        ],
        correctOptionId: 'B',
        explanation: 'Jack-Jack Parr exhibits a hilarious variety of shapeshifting and energetic superpowers.',
        pointValue: 150,
      ),
      Question(
        id: 'q_024',
        category: 'Animation & Family',
        categoryEmoji: '✨',
        difficulty: 'HARD',
        questionText: 'In Hayao Miyazaki\'s masterpiece Spirited Away, what animals are Chihiro\'s parents transformed into?',
        quoteHighlight: '"Punished for gorging on spirit feast"',
        options: [
          Option(id: 'A', text: 'Toads'),
          Option(id: 'B', text: 'Pigs'),
          Option(id: 'C', text: 'Wolves'),
          Option(id: 'D', text: 'Crows'),
        ],
        correctOptionId: 'B',
        explanation: 'Chihiro\'s parents greedily consume food meant for spirits and are turned into pigs.',
        pointValue: 200,
      ),

      // --- GENERAL KNOWLEDGE ---
      Question(
        id: 'q_025',
        category: 'General Knowledge',
        categoryEmoji: '🌍',
        difficulty: 'EASY',
        questionText: 'Which country is home to the famous ancient Great Pyramids of Giza?',
        quoteHighlight: '"Land of the Pharaohs along the Nile"',
        options: [
          Option(id: 'A', text: 'Greece'),
          Option(id: 'B', text: 'Mexico'),
          Option(id: 'C', text: 'Egypt'),
          Option(id: 'D', text: 'Peru'),
        ],
        correctOptionId: 'C',
        explanation: 'The Pyramids of Giza were built along the Nile River in Egypt.',
        pointValue: 100,
      ),
      Question(
        id: 'q_026',
        category: 'General Knowledge',
        categoryEmoji: '🌍',
        difficulty: 'MEDIUM',
        questionText: 'Which is the largest ocean on planet Earth by total surface area?',
        quoteHighlight: '"Covers more area than all land masses combined"',
        options: [
          Option(id: 'A', text: 'Atlantic Ocean'),
          Option(id: 'B', text: 'Indian Ocean'),
          Option(id: 'C', text: 'Pacific Ocean'),
          Option(id: 'D', text: 'Arctic Ocean'),
        ],
        correctOptionId: 'C',
        explanation: 'The Pacific Ocean spans over 60 million square miles, covering over 30% of the globe.',
        pointValue: 150,
      ),
      Question(
        id: 'q_027',
        category: 'General Knowledge',
        categoryEmoji: '🌍',
        difficulty: 'HARD',
        questionText: 'What is the official federal capital city of Australia?',
        quoteHighlight: '"A purpose-built planned national capital"',
        options: [
          Option(id: 'A', text: 'Sydney'),
          Option(id: 'B', text: 'Melbourne'),
          Option(id: 'C', text: 'Brisbane'),
          Option(id: 'D', text: 'Canberra'),
        ],
        correctOptionId: 'D',
        explanation: 'Canberra was selected as Australia\'s capital in 1908 as a compromise between Sydney and Melbourne.',
        pointValue: 200,
      ),
      Question(
        id: 'q_028',
        category: 'General Knowledge',
        categoryEmoji: '🌍',
        difficulty: 'EASY',
        questionText: 'How many continents are there on planet Earth?',
        quoteHighlight: '"Major land divisions of our planet"',
        options: [
          Option(id: 'A', text: '5'),
          Option(id: 'B', text: '6'),
          Option(id: 'C', text: '7'),
          Option(id: 'D', text: '8'),
        ],
        correctOptionId: 'C',
        explanation: 'Earth has seven continents: Asia, Africa, North America, South America, Antarctica, Europe, and Australia.',
        pointValue: 100,
      ),
      Question(
        id: 'q_029',
        category: 'General Knowledge',
        categoryEmoji: '🌍',
        difficulty: 'MEDIUM',
        questionText: 'What is the hardest naturally occurring mineral discovered on Earth?',
        quoteHighlight: '"Pure crystalline carbon under extreme pressure"',
        options: [
          Option(id: 'A', text: 'Quartz'),
          Option(id: 'B', text: 'Topaz'),
          Option(id: 'C', text: 'Corundum'),
          Option(id: 'D', text: 'Diamond'),
        ],
        correctOptionId: 'D',
        explanation: 'Diamond rates as a 10 on the Mohs hardness scale, making it the hardest natural mineral.',
        pointValue: 150,
      ),

      // --- SURPRISE BUZZER BLITZ ---
      Question(
        id: 'q_030',
        category: 'Surprise Buzzer Blitz',
        categoryEmoji: '⚡',
        difficulty: 'HARD',
        questionText: 'Which mammal is documented to possess a bite force exceeding 1,200 PSI?',
        quoteHighlight: '"River giant with devastating jaw power"',
        options: [
          Option(id: 'A', text: 'Grizzly Bear'),
          Option(id: 'B', text: 'Hippopotamus'),
          Option(id: 'C', text: 'African Lion'),
          Option(id: 'D', text: 'Jaguar'),
        ],
        correctOptionId: 'B',
        explanation: 'Hippopotamuses have an astonishing bite force measured above 1,260 PSI, among the strongest on Earth.',
        pointValue: 300,
      ),
      Question(
        id: 'q_031',
        category: 'Surprise Buzzer Blitz',
        categoryEmoji: '⚡',
        difficulty: 'HARD',
        questionText: 'What is the speed of light in a vacuum to the nearest thousand kilometers per second?',
        quoteHighlight: '"Fundamental physical constant c"',
        options: [
          Option(id: 'A', text: '150,000 km/s'),
          Option(id: 'B', text: '300,000 km/s'),
          Option(id: 'C', text: '450,000 km/s'),
          Option(id: 'D', text: '600,000 km/s'),
        ],
        correctOptionId: 'B',
        explanation: 'The speed of light in vacuum is approximately 299,792 km/s, rounded to 300,000 km/s.',
        pointValue: 300,
      ),
      Question(
        id: 'q_032',
        category: 'Surprise Buzzer Blitz',
        categoryEmoji: '⚡',
        difficulty: 'HARD',
        questionText: 'Which bird species is clocked as the fastest animal on the planet during its hunting dive?',
        quoteHighlight: '"Speeds exceeding 240 mph during high-speed stoop"',
        options: [
          Option(id: 'A', text: 'Golden Eagle'),
          Option(id: 'B', text: 'Peregrine Falcon'),
          Option(id: 'C', text: 'Red-tailed Hawk'),
          Option(id: 'D', text: 'Osprey'),
        ],
        correctOptionId: 'B',
        explanation: 'The Peregrine Falcon reaches dive speeds exceeding 240 mph (389 km/h) when hunting in midair.',
        pointValue: 300,
      ),
    ];
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'categoryEmoji': categoryEmoji,
        'difficulty': difficulty,
        'question': questionText,
        'quoteHighlight': quoteHighlight,
        'options': options.map((o) => o.toJson()).toList(),
        'correctOptionId': correctOptionId,
        'explanation': explanation,
        'pointValue': pointValue,
      };
}
