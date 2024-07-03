class Group
  attr_accessor :id, :name, :user_id, :created_at, :updated_at, :icon, :group_amount
  include ActiveModel::Model

  def initialize(attributes = {})
    @id = attributes[:id]
    @name = attributes[:name]
    @user_id = attributes[:user_id]
    @created_at = attributes[:created_at]
    @updated_at = attributes[:updated_at]
    @icon = attributes[:icon] 
    @group_amount = attributes.fetch(:group_amount, 0)
  end

  def save
    session = NEO4J_DRIVER.session
    if id.nil?
      result = session.run("CREATE (g:Group {name: $name, user_id: $user_id, created_at: $created_at, updated_at: $updated_at, group_amount: $group_amount, icon: $icon}) RETURN id(g)", 
                           name: name, user_id: user_id, created_at: DateTime.now.to_s, updated_at: DateTime.now.to_s, group_amount: group_amount, icon: icon)
      @id = result.single[0]
    else
      session.run("MATCH (g:Group) WHERE id(g) = $id SET g += {name: $name, user_id: $user_id, updated_at: $updated_at, group_amount: $group_amount, icon: $icon}", 
                  id: id, name: name, user_id: user_id, updated_at: DateTime.now.to_s, group_amount: group_amount, icon: icon)
    end
    session.close
    self
  end

  def self.find_by(attribute)
    session = NEO4J_DRIVER.session
    query = "MATCH (g:Group) WHERE g.#{attribute.keys.first} = $value RETURN g"
    result = session.run(query, value: attribute.values.first)
    group = result.single&.[](:g)&.properties&.merge(id: result.single[:g].id)
    session.close
    group ? new(group) : nil
  end

  def destroy
    session = NEO4J_DRIVER.session
    session.run("MATCH (u:User)-[r:HAS_GROUP]->(g:Group) WHERE id(g) = $id DELETE r", id: self.id)
    session.run("MATCH (g:Group) WHERE id(g) = $id DELETE g", id: self.id)
    session.close
  end

  def self.find(id)
    session = NEO4J_DRIVER.session
    begin
      query = "MATCH (g:Group) WHERE id(g) = $id RETURN g"
      result = session.run(query, id: id)
      single_record = result.single
      group = single_record[:g].properties.merge(id: single_record[:g].id)
      group ? new(group) : nil
    ensure
      session.close
    end
  end

  def groups
    session = NEO4J_DRIVER.session
    begin
      query = "MATCH (u:User)-[:HAS_GROUP]->(g:Group) WHERE id(u) = $user_id RETURN g"
      results = session.run(query, user_id: self.id)
      groups = results.map do |result|
        group_properties = result[:g].properties.merge(id: result[:g].id)
        Group.new(group_properties)
      end
    ensure
      session.close
    end
    groups
  end
end
