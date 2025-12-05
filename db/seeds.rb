# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Users
# Creating 5 users to study
User.create(email_address: 'user1@elephanto.com', password: 'p@ssword1', password_confirmation: 'p@ssword1', 
            terms_of_service: true, verified: true, confirmed_at: 1.day.ago, admin: true)

User.create(email_address: 'user2@elephanto.com', password: 'p@ssword1', password_confirmation: 'p@ssword1',
            terms_of_service: true, verified: true, confirmed_at: 1.day.ago, admin: true)

User.create(email_address: 'user3@elephanto.com', password: 'p@ssword1', password_confirmation: 'p@ssword1',
            terms_of_service: true, verified: false, admin: false)

User.create(email_address: 'user4@elephanto.com', password: 'p@ssword1', password_confirmation: 'p@ssword1',
            terms_of_service: true, verified: false, admin: false)

User.create(email_address: 'user5@elephanto.com', password: 'p@ssword1', password_confirmation: 'p@ssword1',
            terms_of_service: true, verified: false, admin: false)

# Creatinf profiles
user1 = Profile.create(first_name: "Mariana", last_name: "Silva", username: "mari.silva.art", 
                       bio: "Artista visual e ilustradora digital. Amante da natureza e do café. Compartilhando meu processo criativo e descobertas.", user_id: 1) 

user2 = Profile.create(first_name: "Rafael", last_name: "Costa", username: "rafatech.dev", 
                       bio: "Desenvolvedor full-stack, entusiasta de código aberto e fotografia urbana. Sempre aprendendo e construindo coisas novas.", user_id: 2) 


user3 = Profile.create(first_name: "Beatriz", last_name: "Santos", username: "bia.sustainable.life", 
                       bio: "Educadora ambiental e defensora do consumo consciente. Aqui para compartilhar dicas de sustentabilidade no dia a dia.", user_id: 3) 

user4 = Profile.create(first_name: "Tiago", last_name: "Oliveira", username: "thiago.travelnotes", 
                       bio: "Nômade digital e contador de histórias. Já visitei 37 países e ainda contando. Fotos e reflexões das estradas pelo mundo.", user_id: 4) 

images = %w(maria.jpg rafael.jpg beatriz.jpg tiago.jpg)

images.each_with_index do |image, index|
  image_path = Rails.root.join('db', 'seed_images', image)

  if File.exist?(image_path)
    profile = Profile.find(index + 1)
    profile.avatar.attach(io: File.open(image_path), filename: image, content_type: 'image/jpeg')
    puts "Attached avatar to #{profile.username}"
  else 
    puts "Warning: Default avatar image not found"
  end
end

# Creating 5 decks with different themes
Deck.create(name: "English Vocabulary",   description: "Basic English words and their meanings",              user_id: 1)
Deck.create(name: "Math Formulas",        description: "Common mathematical formulas and their applications", user_id: 2)
Deck.create(name: "History Dates",        description: "Important historical events and dates",               user_id: 3)
Deck.create(name: "Programming Concepts", description: "Fundamental programming concepts and definitions",    user_id: 1)
Deck.create(name: "Science Terms",        description: "Key scientific terms and their explanations",         user_id: 2)

# Creating 10 flashcards for each deck
# English Vocabulary Flashcards
english_deck = Deck.find_by(name: "English Vocabulary")
Flashcard.create([
  { front: "Big",         back: "Large in size or amount",          difficulty: "easy",   deck: english_deck },
  { front: "Run",         back: "To move quickly on foot",          difficulty: "easy",   deck: english_deck },
  { front: "Beautiful",   back: "Pleasing to the senses",           difficulty: "medium", deck: english_deck },
  { front: "Quick",       back: "Fast or rapid",                    difficulty: "easy",   deck: english_deck },
  { front: "Happy",       back: "Feeling or showing pleasure",      difficulty: "easy",   deck: english_deck },
  { front: "Difficult",   back: "Hard to do or understand",         difficulty: "medium", deck: english_deck },
  { front: "Ancient",     back: "Very old or from a long time ago", difficulty: "medium", deck: english_deck },
  { front: "Brave",       back: "Showing courage",                  difficulty: "medium", deck: english_deck },
  { front: "Freedom",     back: "The state of being free",          difficulty: "hard",   deck: english_deck },
  { front: "Magnificent", back: "Very beautiful or impressive",     difficulty: "hard",   deck: english_deck }
])

# Math Formulas Flashcards
math_deck = Deck.find_by(name: "Math Formulas")
Flashcard.create([
  { front: "Area of a Circle",          back: "A = πr²",                    difficulty: "medium", deck: math_deck },
  { front: "Pythagorean Theorem",       back: "a² + b² = c²",               difficulty: "medium", deck: math_deck },
  { front: "Quadratic Formula",         back: "x = (-b ± √(b²-4ac))/(2a)",  difficulty: "hard",   deck: math_deck },
  { front: "Area of a Rectangle",       back: "A = length × width",         difficulty: "easy",   deck: math_deck },
  { front: "Circumference of a Circle", back: "C = 2πr",                    difficulty: "medium", deck: math_deck },
  { front: "Slope Formula",             back: "m = (y₂-y₁)/(x₂-x₁)",        difficulty: "medium", deck: math_deck },
  { front: "Volume of a Cube",          back: "V = s³",                     difficulty: "easy",   deck: math_deck },
  { front: "Distance Formula",          back: "d = √((x₂-x₁)² + (y₂-y₁)²)", difficulty: "hard",   deck: math_deck },
  { front: "Area of a Triangle",        back: "A = (base × height)/2",      difficulty: "medium", deck: math_deck },
  { front: "Perimeter of a Square",     back: "P = 4s",                     difficulty: "easy",   deck: math_deck }
])

# History Dates Flashcards
history_deck = Deck.find_by(name: "History Dates")
Flashcard.create([
  { front: "Fall of the Berlin Wall", back: "1989", difficulty: "medium", deck: history_deck },
  { front: "American Independence", back: "1776", difficulty: "easy", deck: history_deck },
  { front: "World War II End", back: "1945", difficulty: "medium", deck: history_deck },
  { front: "French Revolution Start", back: "1789", difficulty: "medium", deck: history_deck },
  { front: "Moon Landing", back: "1969", difficulty: "easy", deck: history_deck },
  { front: "World War I Start", back: "1914", difficulty: "medium", deck: history_deck },
  { front: "Discovery of America", back: "1492", difficulty: "easy", deck: history_deck },
  { front: "Russian Revolution", back: "1917", difficulty: "hard", deck: history_deck },
  { front: "Civil Rights Act", back: "1964", difficulty: "medium", deck: history_deck },
  { front: "End of Cold War", back: "1991", difficulty: "hard", deck: history_deck }
])

# Programming Concepts Flashcards
programming_deck = Deck.find_by(name: "Programming Concepts")
Flashcard.create([
  { front: "Variable",    back: "A named storage location in memory",                               difficulty: "easy",   deck: programming_deck },
  { front: "Function",    back: "A block of code that performs a specific task",                    difficulty: "medium", deck: programming_deck },
  { front: "Loop",        back: "A control structure that repeats a block of code",                 difficulty: "medium", deck: programming_deck },
  { front: "Array",       back: "A collection of elements stored at contiguous memory locations",   difficulty: "medium", deck: programming_deck },
  { front: "Class",       back: "A blueprint for creating objects",                                 difficulty: "hard",   deck: programming_deck },
  { front: "Object",      back: "An instance of a class",                                           difficulty: "medium", deck: programming_deck },
  { front: "Conditional", back: "A statement that performs different actions based on a condition", difficulty: "medium", deck: programming_deck },
  { front: "Algorithm",   back: "A set of instructions to solve a problem",                         difficulty: "hard",   deck: programming_deck },
  { front: "Debugging",   back: "The process of finding and fixing errors in code",                 difficulty: "medium", deck: programming_deck },
  { front: "Inheritance", back: "A mechanism where a class inherits properties from another class", difficulty: "hard",   deck: programming_deck }
])

# Science Terms Flashcards
science_deck = Deck.find_by(name: "Science Terms")
Flashcard.create([
  { front: "Photosynthesis", back: "Process by which plants make food using sunlight",      difficulty: "medium", deck: science_deck },
  { front: "Gravity",        back: "Force that attracts objects towards each other",        difficulty: "easy",   deck: science_deck },
  { front: "Atom",           back: "Smallest unit of a chemical element",                   difficulty: "medium", deck: science_deck },
  { front: "DNA",            back: "Molecule that carries genetic information",             difficulty: "hard",   deck: science_deck },
  { front: "Ecosystem",      back: "A community of living organisms and their environment", difficulty: "medium", deck: science_deck },
  { front: "Energy",         back: "The capacity to do work",                               difficulty: "easy",   deck: science_deck },
  { front: "Molecule",       back: "A group of atoms bonded together",                      difficulty: "medium", deck: science_deck },
  { front: "Evolution",      back: "Change in species over time",                           difficulty: "hard",   deck: science_deck },
  { front: "Force",          back: "A push or pull on an object",                           difficulty: "easy", deck: science_deck },
  { front: "Cell",           back: "The basic unit of life",                                difficulty: "medium", deck: science_deck }
])
