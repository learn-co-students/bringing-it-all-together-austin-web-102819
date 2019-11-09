require 'pry'
class Dog
    attr_accessor :name, :breed, :id

    def initialize(attributes)
        attributes.each do |k, v|
            self.send("#{k}=", v)
        end
    end

    def self.create_table
        sql = <<-SQL
                CREATE TABLE dogs (
                    id INTEGER PRIMARY KEY,
                    name TEXT,
                    breed TEXT
                )
              SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
                DROP TABLE dogs
              SQL
        DB[:conn].execute(sql)
    end

    def save
        sql = <<-SQL
                INSERT INTO dogs (name, breed)
                VALUES (?, ?)
              SQL
        DB[:conn].execute(sql, self.name, self.breed)

        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        Dog.new(name: self.name, breed: self.breed, id: self.id)
    end

    def self.create(attributes)
        dog = Dog.new(attributes)
        dog.save
    end

    def self.new_from_db(row)
        # binding.pry
        dog = Dog.new(id: row[0], name: row[1], breed: row[2])
        dog
    end

    def self.find_by_id(id)
        sql = <<-SQL
                SELECT * FROM dogs 
                WHERE id = ?
              SQL
        row = DB[:conn].execute(sql, id)[0]
        
        self.new_from_db(row)
    end

    def self.find_or_create_by(attributes)
        
        sql = <<-SQL
                SELECT * FROM dogs WHERE
                name = ? and breed = ?
              SQL
        dog = DB[:conn].execute(sql, attributes[:name], attributes[:breed])[0]
        if dog
            self.new_from_db(dog)
        else
            self.create(attributes)
        end
    end

    def update
        sql = <<-SQL
                UPDATE dogs SET name = ?
                WHERE id = ?
              SQL
        DB[:conn].execute(sql, self.name, self.id)
    end

    def self.find_by_name(name)
        
        sql = <<-SQL
                SELECT * FROM dogs WHERE name = ?
              SQL
        DB[:conn].execute(sql, name).map do |row|
            self.new_from_db(row)
        end.first
    end
end

