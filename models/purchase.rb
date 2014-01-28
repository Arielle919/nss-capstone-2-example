class Purchase
  attr_accessor :name, :price, :calories
  attr_reader :id

  def initialize attributes = {}
    update_attributes(attributes)
  end

  def self.create(attributes = {})
    purchase = Purchase.new(attributes)
    purchase.save
    purchase
  end

  def update attributes = {}
    update_attributes(attributes)
    save
  end

  def save
    database = Environment.database_connection
    if id
      database.execute("update purchases set name = '#{name}', calories = '#{calories}', price = '#{price}' where id = #{id}")
    else
      database.execute("insert into purchases(name, calories, price) values('#{name}', #{calories}, #{price})")
      @id = database.last_insert_row_id
    end
    # ^ fails silently!!
    # ^ Also, susceptible to SQL injection!
  end

  def self.find id
    database = Environment.database_connection
    database.results_as_hash = true
    results = database.execute("select * from purchases where id = #{id}")[0]
    if results
      purchase = Purchase.new(name: results["name"], price: results["price"], calories: results["calories"])
      purchase.send("id=", results["id"])
      purchase
    else
      nil
    end
  end

  def self.search(search_term)
    database = Environment.database_connection
    database.results_as_hash = true
    results = database.execute("select purchases.name from purchases where name LIKE '%#{search_term}%'")
    results.map do |row_hash|
      purchase = Purchase.new(name: row_hash["name"], price: row_hash["price"], calories: row_hash["calories"])
      purchase.send("id=", row_hash["id"])
      purchase
    end
  end

  def self.all
    database = Environment.database_connection
    database.results_as_hash = true
    results = database.execute("select * from purchases order by name ASC")
    results.map do |row_hash|
      purchase = Purchase.new(name: row_hash["name"], price: row_hash["price"], calories: row_hash["calories"])
      purchase.send("id=", row_hash["id"])
      purchase
    end
  end

  def price
    sprintf('%.2f', @price) if @price
  end

  def to_s
    "#{name}: #{calories} calories, $#{price}, id: #{id}"
  end

  def ==(other)
    other.is_a?(Purchase) && self.to_s == other.to_s
  end

  protected

  def id=(id)
    @id = id
  end

  def update_attributes(attributes)
    # @price = attributes[:price]
    # @calories = attributes[:calories]
    # @name = attributes[:name]
    # ^ Long way
    # Short way:
    [:name, :price, :calories].each do |attr|
      if attributes[attr]
        # self.calories = attributes[:calorie]
        self.send("#{attr}=", attributes[attr])
      end
    end
  end
end
