/// Country, with its phone dial code, offered in the signup country picker.
/// `dialCode` is shown to the user as a prefix next to the phone field but
/// is never sent to the backend — `User.phone` stores only the bare local
/// number (see `SignupRequest`), and the selected country name alone is
/// what's submitted as `country`.
class Country {
  const Country({required this.name, required this.dialCode});

  final String name;
  final String dialCode;

  @override
  String toString() => name;
}

/// Curated rather than exhaustive — countries likely relevant to this app's
/// audience, not every ISO country. India is listed first as the default
/// selection since the app's content is Hindi-language.
const List<Country> countries = [
  Country(name: 'India', dialCode: '+91'),
  Country(name: 'United States', dialCode: '+1'),
  Country(name: 'United Kingdom', dialCode: '+44'),
  Country(name: 'Canada', dialCode: '+1'),
  Country(name: 'Australia', dialCode: '+61'),
  Country(name: 'United Arab Emirates', dialCode: '+971'),
  Country(name: 'Singapore', dialCode: '+65'),
  Country(name: 'New Zealand', dialCode: '+64'),
  Country(name: 'South Africa', dialCode: '+27'),
  Country(name: 'Germany', dialCode: '+49'),
  Country(name: 'France', dialCode: '+33'),
  Country(name: 'Qatar', dialCode: '+974'),
  Country(name: 'Saudi Arabia', dialCode: '+966'),
  Country(name: 'Kuwait', dialCode: '+965'),
  Country(name: 'Mauritius', dialCode: '+230'),
  Country(name: 'Malaysia', dialCode: '+60'),
];
