class String
  def lower_camel_case
    value = self.split('_').each {|s| s.capitalize! }.join('')
    value[0, 1].downcase + value[1..-1]
  end
end