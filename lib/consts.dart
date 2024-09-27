final RegExp EMAIL_VALIDATION_REGEX =
    RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");

final RegExp PASSWORD_VALIDATION_REGEX =
    RegExp(r"^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.[a-zA-Z]).{8,}$");

final RegExp NAME_VALIDTAION_REGEX = RegExp(r"\b([A-ZA-y][-,a-z. ']+[ ]*)+");


