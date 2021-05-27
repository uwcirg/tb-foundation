#Calculating Patient Priority
#Using information from this standards doccument https://docs.google.com/document/d/1Vw-k8SOZ0rnpE9-OkAhjCZDkNNfZEWFpK2RY1hXHsIY/edit

class PriorityCalculator

  #Precondition: takes in valid patient object
  def initialize(adherence,had_symptoms,had_severe_symptoms, missed_or_negative_photo)
    @adherence = adherence
    @had_symptoms = had_symptoms
    @had_severe_symptoms = had_severe_symptoms
  end

  def calculate_priority
    if(adherence < .9 || had_severe_symptoms){
      return 2
    }elsif(adherence < .95 || had_symptoms){
      return 1
    }else{
      return 0
    }
  end 

end
