#Calculating Patient Priority
#Using information from this standards doccument https://docs.google.com/document/d/1Vw-k8SOZ0rnpE9-OkAhjCZDkNNfZEWFpK2RY1hXHsIY/edit

class PriorityCalculator

  #Precondition: takes in valid patient object
  def initialize(patient)
    @adherence = patient.adherence
    @had_low_alert_symptoms = patient.daily_reports.last_week.where(symptom_report: SymptomReport.low_alert).exists?
    @had_high_alert_symptoms = patient.daily_reports.last_week.where(symptom_report: SymptomReport.high_alert).exists?
  end

  def priority
    if (check_high_priority)
      return 2
    elsif (check_med_priority)
      return 1
    end
    return 0
  end

  def reason
    print("adherence:#{@adherence} low_alert:#{@had_low_alert_symptoms} high_alert:#{@had_high_alert_symptoms}")
  end

  private

  #Reported adherence < 90%
  #Reporting HIGH ALERT symptom/side effect in the past 7 days
  def check_high_priority
    return (@adherence < 0.9 || @had_high_alert_symptoms)
  end

  #Adherence percentage between 90-95%
  #Reporting a LOW ALERT symptom/side effect in the past 7 days
  def check_med_priority
    return ((@adherence < 0.95 && @adherence >= 0.9) || @had_low_alert_symptoms)
  end

end
