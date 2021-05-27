#Calculating Patient Priority
#Using information from this standards doccument https://docs.google.com/document/d/1Vw-k8SOZ0rnpE9-OkAhjCZDkNNfZEWFpK2RY1hXHsIY/edit

class PriorityCalculator

  #Precondition: takes in valid patient object
  def initialize(adherence, had_symptoms, had_severe_symptoms, missed_or_negative_photo)
    @adherence = adherence
    @had_symptoms = had_symptoms
    @had_severe_symptoms = had_severe_symptoms
    @missed_or_negative_photo = missed_or_negative_photo
  end

  def calculate

    if (@adherence < 0.9 or @had_severe_symptoms or @missed_or_negative_photo)
      return 2
    elsif (@adherence < 0.95 or @had_symptoms)
      return 1
    end

    0

  end 

end
