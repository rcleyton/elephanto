# Demo data only. Never seed shared or production databases with known passwords.
# Natural keys and associations make repeated runs safe without resetting study progress.
if Rails.env.development? || Rails.env.test?
  ActiveRecord::Base.transaction do
    users = (1..5).map do |number|
      User.find_or_create_by!(email_address: "user#{number}@elephanto.com") do |user|
        user.password = "p@ssword1"
        user.password_confirmation = "p@ssword1"
        user.terms_of_service = true
        user.verified = number <= 2
        user.confirmed_at = 1.day.ago if user.verified?
        user.admin = number <= 2
      end
    end

    profile_data = [
      { first_name: "Mariana", last_name: "Silva", username: "mari.silva.art",
        bio: "Artista visual e ilustradora digital. Amante da natureza e do café. Compartilhando meu processo criativo e descobertas.", image: "maria.jpg" },
      { first_name: "Rafael", last_name: "Costa", username: "rafatech.dev",
        bio: "Desenvolvedor full-stack, entusiasta de código aberto e fotografia urbana. Sempre aprendendo e construindo coisas novas.", image: "rafael.jpg" },
      { first_name: "Beatriz", last_name: "Santos", username: "bia.sustainable.life",
        bio: "Educadora ambiental e defensora do consumo consciente. Aqui para compartilhar dicas de sustentabilidade no dia a dia.", image: "beatriz.jpg" },
      { first_name: "Tiago", last_name: "Oliveira", username: "thiago.travelnotes",
        bio: "Nômade digital e contador de histórias. Já visitei 37 países e ainda contando. Fotos e reflexões das estradas pelo mundo.", image: "tiago.jpg" }
    ]

    profile_data.each_with_index do |attributes, index|
      profile = Profile.find_or_create_by!(user: users[index]) do |record|
        record.assign_attributes(attributes.except(:image).merge(location: "SP", daily_new_limit: 20, daily_review_limit: 100))
      end
      image_path = Rails.root.join("db", "seed_images", attributes.fetch(:image))

      if !profile.avatar.attached? && File.exist?(image_path)
        profile.avatar.attach(io: StringIO.new(File.binread(image_path)), filename: attributes.fetch(:image), content_type: "image/jpeg")
      end
    end

    deck_data = [
      { name: "English Vocabulary", description: "Basic English words and their meanings", tag: "Englis", user: users[0] },
      { name: "Math Formulas", description: "Common mathematical formulas and their applications", tag: "Math", user: users[1] },
      { name: "History Dates", description: "Important historical events and dates", tag: "History", user: users[2] },
      { name: "Programming Concepts", description: "Fundamental programming concepts and definitions", tag: "Programming", user: users[0] },
      { name: "Science Terms", description: "Key scientific terms and their explanations", tag: "Science", user: users[1] }
    ]

    decks = deck_data.map do |attributes|
      attributes.fetch(:user).decks.find_or_create_by!(name: attributes.fetch(:name)) do |deck|
        deck.assign_attributes(attributes.except(:user, :name))
      end
    end

    # Creating 10 flashcards for each deck
    # English Vocabulary Flashcards
    english_deck = decks[0]
    [
      { front: "Big",         back: "Large in size or amount",          deck: english_deck },
      { front: "Run",         back: "To move quickly on foot",          deck: english_deck },
      { front: "Beautiful",   back: "Pleasing to the senses",           deck: english_deck },
      { front: "Quick",       back: "Fast or rapid",                    deck: english_deck },
      { front: "Happy",       back: "Feeling or showing pleasure",      deck: english_deck },
      { front: "Difficult",   back: "Hard to do or understand",         deck: english_deck },
      { front: "Ancient",     back: "Very old or from a long time ago", deck: english_deck },
      { front: "Brave",       back: "Showing courage",                  deck: english_deck },
      { front: "Freedom",     back: "The state of being free",          deck: english_deck },
      { front: "Magnificent", back: "Very beautiful or impressive",     deck: english_deck }
    ].each do |attributes|
      attributes.fetch(:deck).flashcards.find_or_create_by!(front: attributes.fetch(:front)) do |flashcard|
        flashcard.back = attributes.fetch(:back)
      end
    end

    # Math Formulas Flashcards
    math_deck = decks[1]
    [
      { front: "Area of a Circle",          back: "A = πr²",                    deck: math_deck },
      { front: "Pythagorean Theorem",       back: "a² + b² = c²",               deck: math_deck },
      { front: "Quadratic Formula",         back: "x = (-b ± √(b²-4ac))/(2a)",  deck: math_deck },
      { front: "Area of a Rectangle",       back: "A = length × width",         deck: math_deck },
      { front: "Circumference of a Circle", back: "C = 2πr",                    deck: math_deck },
      { front: "Slope Formula",             back: "m = (y₂-y₁)/(x₂-x₁)",        deck: math_deck },
      { front: "Volume of a Cube",          back: "V = s³",                     deck: math_deck },
      { front: "Distance Formula",          back: "d = √((x₂-x₁)² + (y₂-y₁)²)", deck: math_deck },
      { front: "Area of a Triangle",        back: "A = (base × height)/2",      deck: math_deck },
      { front: "Perimeter of a Square",     back: "P = 4s",                     deck: math_deck }
    ].each do |attributes|
      attributes.fetch(:deck).flashcards.find_or_create_by!(front: attributes.fetch(:front)) do |flashcard|
        flashcard.back = attributes.fetch(:back)
      end
    end

    # History Dates Flashcards
    history_deck = decks[2]
    [
      { front: "Fall of the Berlin Wall", back: "1989", deck: history_deck },
      { front: "American Independence", back: "1776",   deck: history_deck },
      { front: "World War II End", back: "1945",        deck: history_deck },
      { front: "French Revolution Start", back: "1789", deck: history_deck },
      { front: "Moon Landing", back: "1969",            deck: history_deck },
      { front: "World War I Start", back: "1914",       deck: history_deck },
      { front: "Discovery of America", back: "1492",    deck: history_deck },
      { front: "Russian Revolution", back: "1917",      deck: history_deck },
      { front: "Civil Rights Act", back: "1964",        deck: history_deck },
      { front: "End of Cold War", back: "1991",         deck: history_deck }
    ].each do |attributes|
      attributes.fetch(:deck).flashcards.find_or_create_by!(front: attributes.fetch(:front)) do |flashcard|
        flashcard.back = attributes.fetch(:back)
      end
    end

    # Programming Concepts Flashcards
    programming_deck = decks[3]
    [
      { front: "Variable",    back: "A named storage location in memory",                               deck: programming_deck },
      { front: "Function",    back: "A block of code that performs a specific task",                    deck: programming_deck },
      { front: "Loop",        back: "A control structure that repeats a block of code",                 deck: programming_deck },
      { front: "Array",       back: "A collection of elements stored at contiguous memory locations",   deck: programming_deck },
      { front: "Class",       back: "A blueprint for creating objects",                                 deck: programming_deck },
      { front: "Object",      back: "An instance of a class",                                           deck: programming_deck },
      { front: "Conditional", back: "A statement that performs different actions based on a condition", deck: programming_deck },
      { front: "Algorithm",   back: "A set of instructions to solve a problem",                         deck: programming_deck },
      { front: "Debugging",   back: "The process of finding and fixing errors in code",                 deck: programming_deck },
      { front: "Inheritance", back: "A mechanism where a class inherits properties from another class", deck: programming_deck }
    ].each do |attributes|
      attributes.fetch(:deck).flashcards.find_or_create_by!(front: attributes.fetch(:front)) do |flashcard|
        flashcard.back = attributes.fetch(:back)
      end
    end

    # Science Terms Flashcards
    science_deck = decks[4]
    [
      { front: "Photosynthesis", back: "Process by which plants make food using sunlight",      deck: science_deck },
      { front: "Gravity",        back: "Force that attracts objects towards each other",        deck: science_deck },
      { front: "Atom",           back: "Smallest unit of a chemical element",                   deck: science_deck },
      { front: "DNA",            back: "Molecule that carries genetic information",             deck: science_deck },
      { front: "Ecosystem",      back: "A community of living organisms and their environment", deck: science_deck },
      { front: "Energy",         back: "The capacity to do work",                               deck: science_deck },
      { front: "Molecule",       back: "A group of atoms bonded together",                      deck: science_deck },
      { front: "Evolution",      back: "Change in species over time",                           deck: science_deck },
      { front: "Force",          back: "A push or pull on an object",                           deck: science_deck },
      { front: "Cell",           back: "The basic unit of life",                                deck: science_deck }
    ].each do |attributes|
      attributes.fetch(:deck).flashcards.find_or_create_by!(front: attributes.fetch(:front)) do |flashcard|
        flashcard.back = attributes.fetch(:back)
      end
    end
  end
else
  puts "Skipping demo seeds outside development and test."
end
