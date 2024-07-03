class User
  attr_accessor :id, :name, :email, :encrypted_password, :created_at, :updated_at
  include ActiveModel::Model

  def initialize(attributes = {})
    @id = attributes[:id]
    @name = attributes[:name]
    @email = attributes[:email]
    @encrypted_password = attributes[:encrypted_password]
    @created_at = attributes[:created_at]
    @updated_at = attributes[:updated_at]
  end

  # Implementação de um método personalizado para buscar por qualquer atributo
  def self.find_by(attribute)
    session = NEO4J_DRIVER.session
    query = "MATCH (u:User) WHERE u.#{attribute.keys.first} = $value RETURN u"
    result = session.run(query, value: attribute.values.first)
    user = result.single&.[](:u)&.properties&.merge(id: result.single[:u].id)
    session.close
    user ? new(user) : nil
  end

  def save
    session = NEO4J_DRIVER.session
    if id.nil?
      result = session.run("CREATE (u:User {name: $name, email: $email, encrypted_password: $encrypted_password}) RETURN id(u)", name: name, email: email, encrypted_password: encrypted_password)
      @id = result.single[0]
    else
      session.run("MATCH (u:User) WHERE id(u) = $id SET u += {name: $name, email: $email, encrypted_password: $encrypted_password}", id: id, name: name, email: email, encrypted_password: encrypted_password)
    end
    session.close
    self
  end

  def self.find(id)
    session = NEO4J_DRIVER.session
    begin
      query = "MATCH (u:User) WHERE id(u) = $id RETURN u"
      result = session.run(query, id: id)
      single_record = result.single
      user = single_record[:u].properties.merge(id: single_record[:u].id)
      user ? new(user) : nil
    ensure
      session.close
    end
  end

  def create_group(attributes)
    attributes[:user_id] = self.id  # Atribui o ID do usuário ao grupo
    group = Group.new(attributes)
    if group.save
      # Cria a relação após o grupo ser salvo com sucesso
      create_group_relationship(group.id)
      return group
    else
      return nil
    end
  end
  
  def create_group_relationship(group_id)
    session = NEO4J_DRIVER.session
    query = "MATCH (u:User), (g:Group) WHERE id(u) = $user_id AND id(g) = $group_id CREATE (u)-[:HAS_GROUP]->(g)"
    session.run(query, user_id: self.id, group_id: group_id)
    session.run("MATCH (o:Group) WHERE id(o) = $id SET o.group_id = $group_id",
              id: group_id,
              group_id: group_id)
    session.close
  end

  def groups
    session = NEO4J_DRIVER.session
    begin
      query = "MATCH (u:User)-[:HAS_GROUP]->(g:Group) WHERE id(u) = $user_id RETURN g"
      results = session.run(query, user_id: self.id)
      # Imediatamente transformar os resultados em uma lista de grupos antes de fechar a sessão.
      groups = results.map do |result|
        group_properties = result[:g].properties.merge(id: result[:g].id)
        Group.new(group_properties)
      end
    ensure
      session.close  # Garantir que a sessão é fechada mesmo se ocorrer um erro.
    end
    groups
  end
end
