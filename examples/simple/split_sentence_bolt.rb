class SplitSentenceBolt < RedStorm::SimpleBolt
  output_fields :word

  # block declaration style using auto-emit (default)
  #
  on_receive {|tuple| tuple.getString(0).split(' ').map{|w| [w]}}

  # block declaration style no auto-emit
  #
  # on_receive :emit => false do |tuple| 
  #   tuple.getString(0).split(' ').each{|w| emit(w)}
  # end

  # alternate declaration style using on_receive method
  #
  # on_receive :emit => false
  # def on_receive(tuple)
  #   tuple.getString(0).split(' ').map{|w| [w]}
  # end

  # alternate declaration style using any specific method
  #
  # on_receive :my_method, :emit => false
  # def my_method(tuple)
  #   tuple.getString(0).split(' ').map{|w| [w]}
  # end
end
