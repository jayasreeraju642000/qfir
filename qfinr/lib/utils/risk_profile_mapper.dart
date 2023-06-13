class RiskProfileMapper {
  static String convertToReadableString(String data) {
    if(data == "conservative") {
      return "Conservative";
    } else if (data == "m_conservative") {
      return "Moderate Conservative";
    } else if (data == "moderate") {
      return "Moderate";
    } else if (data == "s_aggressive") {
      return "Moderate Aggressive";
    } else {
      return "Aggressive";
    }
  }
}