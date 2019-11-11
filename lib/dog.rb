class Dog

    attr_accessor :id, :name, :breed

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def update()
        sql = 
        <<-SQL
        update dogs
        set name = ?
        where id = ?
        SQL
        DB[:conn].execute(sql, self.name, self.id)
    end

    def save
        sql =
        <<-SQL
        insert into dogs
        (name, breed)
        values (?, ?)
        SQL
        row = DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("select last_insert_rowid() from dogs")[0][0]
        self
    end

    def self.create_table
        sql = 
        <<-SQL
        create table if not exists dogs
        (id INTEGER primary key, name text, breed text)
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql =
        <<-SQL
        drop table dogs
        SQL
        DB[:conn].execute(sql)
    end

    def self.create(name:, breed:)
        new_dog = Dog.new(name: name, breed: breed)
        new_dog.save
    end

    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_id(id)
        sql = 
        <<-SQL
        select * from dogs
        where id = ?
        SQL
        dog = DB[:conn].execute(sql, id)
        if !dog.empty?
            return self.new_from_db(dog[0])
        end
    end

    def self.find_by_name(name)
        sql = 
        <<-SQL
        select * from dogs
        where name = ?
        SQL
        dog = DB[:conn].execute(sql, name)
        if !dog.empty?
            return self.new_from_db(dog[0])
        end
    end

    def self.find_or_create_by(name:, breed:)
        sql = 
        <<-SQL
        select * from dogs
        where name = ? and breed = ?
        SQL
        dog = DB[:conn].execute(sql, name, breed)
        if !dog.empty?
            new_dog = Dog.new(name: name, breed: breed)
            new_dog.id = dog[0][0]
        else
            new_dog = self.create(name: name, breed: breed)
        end
        new_dog
    end

end