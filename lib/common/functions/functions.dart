import 'package:intl/intl.dart';


class CommonFunction{

 static String formatDate(String dateString) {
  if (dateString.isEmpty) {
    return "";
  }
  // Parse the given date string into a DateTime object
  DateTime dateTime = DateTime.parse(dateString);

  // Create a DateFormat object for the desired format
  DateFormat formatter = DateFormat('dd-MM-yyyy');

  // Format the DateTime object into the desired format
  String formattedDate = formatter.format(dateTime);

  return formattedDate;
}

}

