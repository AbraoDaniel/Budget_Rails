class User
  attr_accessor :id, :name, :email, :encrypted_password

  def initialize(attributes = {})
    @id = attributes[:id]
    @name = attributes[:name]
    @email = attributes[:email]
    @encrypted_password = attributes[:encrypted_password]  # Simplificação, deve ser gerenciado com cuidado!
  end

  def self.all
    session = NEO4J_DRIVER.session
    result = session.run("MATCH (u:User) RETURN u")
    users = result.map { |record| new(record[:u].properties.merge(id: record[:u].id)) }
    session.close
    users
  end

  def save
    session = NEO4J_DRIVER.session
    if id.nil?
      result = session.run("CREATE (u:User {name: $name, email: $email, encrypted_password: $encrypted_password}) RETURN id(u)", name: name, email: email, encrypted_password: encrypted_password)
      @id = result.single[0].as_int
    else
      session.run("MATCH (u:User) WHERE id(u) = $id SET u += {name: $name, email: $email, encrypted_password: $encrypted_password}", id: id, name: name, email: email, encrypted_password: encrypted_password)
    end
    session.close
    self
  end

  def destroy
    session = NEO4J_DRIVER.session
    session.run("MATCH (u:User) WHERE id(u) = $id DELETE u", id: id)
    session.close
  end

  def self.find(id)
    session = NEO4J_DRIVER.session
    result = session.run("MATCH (u:User) WHERE id(u) = $id RETURN u", id: id)
    user = new(result.single[0][:u].properties.merge(id: id))
    session.close
    user
  end
end
