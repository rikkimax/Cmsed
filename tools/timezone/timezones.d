module cmsed.base.timezones;
import std.datetime;

enum TimeZones {
    Africa_Cairo,
    Africa_Casablanca,
    Africa_Johannesburg,
    Africa_Lagos,
    Africa_Nairobi,
    Africa_Tripoli,
    Africa_Windhoek,
    America_Anchorage,
    America_Asuncion,
    America_Bahia,
    America_Bogota,
    America_Buenos_Aires,
    America_Caracas,
    America_Cayenne,
    America_Chicago,
    America_Chihuahua,
    America_Cuiaba,
    America_Denver,
    America_Godthab,
    America_Guatemala,
    America_Halifax,
    America_La_Paz,
    America_Los_Angeles,
    America_Mexico_City,
    America_Montevideo,
    America_New_York,
    America_Phoenix,
    America_Regina,
    America_Santa_Isabel,
    America_Santiago,
    America_Sao_Paulo,
    America_St_Johns,
    Asia_Almaty,
    Asia_Amman,
    Asia_Baghdad,
    Asia_Baku,
    Asia_Bangkok,
    Asia_Beirut,
    Asia_Calcutta,
    Asia_Colombo,
    Asia_Damascus,
    Asia_Dhaka,
    Asia_Dubai,
    Asia_Irkutsk,
    Asia_Jerusalem,
    Asia_Kabul,
    Asia_Kamchatka,
    Asia_Karachi,
    Asia_Katmandu,
    Asia_Krasnoyarsk,
    Asia_Magadan,
    Asia_Novosibirsk,
    Asia_Rangoon,
    Asia_Riyadh,
    Asia_Seoul,
    Asia_Shanghai,
    Asia_Singapore,
    Asia_Taipei,
    Asia_Tashkent,
    Asia_Tbilisi,
    Asia_Tehran,
    Asia_Tokyo,
    Asia_Ulaanbaatar,
    Asia_Vladivostok,
    Asia_Yakutsk,
    Asia_Yekaterinburg,
    Asia_Yerevan,
    Atlantic_Azores,
    Atlantic_Cape_Verde,
    Atlantic_Reykjavik,
    Australia_Adelaide,
    Australia_Brisbane,
    Australia_Darwin,
    Australia_Hobart,
    Australia_Perth,
    Australia_Sydney,
    Europe_Berlin,
    Europe_Budapest,
    Europe_Istanbul,
    Europe_Kaliningrad,
    Europe_Kiev,
    Europe_London,
    Europe_Minsk,
    Europe_Moscow,
    Europe_Paris,
    Europe_Warsaw,
    Indian_Mauritius,
    Pacific_Apia,
    Pacific_Auckland,
    Pacific_Fiji,
    Pacific_Guadalcanal,
    Pacific_Honolulu,
    Pacific_Port_Moresby,
    Pacific_Tongatapu,
}

const string[] TimeZoneNames = [
    "Africa/Cairo",
    "Africa/Casablanca",
    "Africa/Johannesburg",
    "Africa/Lagos",
    "Africa/Nairobi",
    "Africa/Tripoli",
    "Africa/Windhoek",
    "America/Anchorage",
    "America/Asuncion",
    "America/Bahia",
    "America/Bogota",
    "America/Buenos_Aires",
    "America/Caracas",
    "America/Cayenne",
    "America/Chicago",
    "America/Chihuahua",
    "America/Cuiaba",
    "America/Denver",
    "America/Godthab",
    "America/Guatemala",
    "America/Halifax",
    "America/La_Paz",
    "America/Los_Angeles",
    "America/Mexico_City",
    "America/Montevideo",
    "America/New_York",
    "America/Phoenix",
    "America/Regina",
    "America/Santa_Isabel",
    "America/Santiago",
    "America/Sao_Paulo",
    "America/St_Johns",
    "Asia/Almaty",
    "Asia/Amman",
    "Asia/Baghdad",
    "Asia/Baku",
    "Asia/Bangkok",
    "Asia/Beirut",
    "Asia/Calcutta",
    "Asia/Colombo",
    "Asia/Damascus",
    "Asia/Dhaka",
    "Asia/Dubai",
    "Asia/Irkutsk",
    "Asia/Jerusalem",
    "Asia/Kabul",
    "Asia/Kamchatka",
    "Asia/Karachi",
    "Asia/Katmandu",
    "Asia/Krasnoyarsk",
    "Asia/Magadan",
    "Asia/Novosibirsk",
    "Asia/Rangoon",
    "Asia/Riyadh",
    "Asia/Seoul",
    "Asia/Shanghai",
    "Asia/Singapore",
    "Asia/Taipei",
    "Asia/Tashkent",
    "Asia/Tbilisi",
    "Asia/Tehran",
    "Asia/Tokyo",
    "Asia/Ulaanbaatar",
    "Asia/Vladivostok",
    "Asia/Yakutsk",
    "Asia/Yekaterinburg",
    "Asia/Yerevan",
    "Atlantic/Azores",
    "Atlantic/Cape_Verde",
    "Atlantic/Reykjavik",
    "Australia/Adelaide",
    "Australia/Brisbane",
    "Australia/Darwin",
    "Australia/Hobart",
    "Australia/Perth",
    "Australia/Sydney",
    "Europe/Berlin",
    "Europe/Budapest",
    "Europe/Istanbul",
    "Europe/Kaliningrad",
    "Europe/Kiev",
    "Europe/London",
    "Europe/Minsk",
    "Europe/Moscow",
    "Europe/Paris",
    "Europe/Warsaw",
    "Indian/Mauritius",
    "Pacific/Apia",
    "Pacific/Auckland",
    "Pacific/Fiji",
    "Pacific/Guadalcanal",
    "Pacific/Honolulu",
    "Pacific/Port_Moresby",
    "Pacific/Tongatapu",
];


shared Duration[TimeZones] utcOffset;

static this() {
    rebuildTimeZones();
}

void rebuildTimeZones() {
    auto currentTime = Clock.currTime().toUnixTime();
    utcOffset[TimeZones.Africa_Cairo] = TimeZone.getTimeZone("Africa/Cairo").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Africa_Casablanca] = TimeZone.getTimeZone("Africa/Casablanca").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Africa_Johannesburg] = TimeZone.getTimeZone("Africa/Johannesburg").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Africa_Lagos] = TimeZone.getTimeZone("Africa/Lagos").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Africa_Nairobi] = TimeZone.getTimeZone("Africa/Nairobi").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Africa_Tripoli] = TimeZone.getTimeZone("Africa/Tripoli").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Africa_Windhoek] = TimeZone.getTimeZone("Africa/Windhoek").utcOffsetAt(currentTime);
    utcOffset[TimeZones.America_Anchorage] = TimeZone.getTimeZone("America/Anchorage").utcOffsetAt(currentTime);
    utcOffset[TimeZones.America_Asuncion] = TimeZone.getTimeZone("America/Asuncion").utcOffsetAt(currentTime);
    utcOffset[TimeZones.America_Bahia] = TimeZone.getTimeZone("America/Bahia").utcOffsetAt(currentTime);
    utcOffset[TimeZones.America_Bogota] = TimeZone.getTimeZone("America/Bogota").utcOffsetAt(currentTime);
    utcOffset[TimeZones.America_Buenos_Aires] = TimeZone.getTimeZone("America/Buenos_Aires").utcOffsetAt(currentTime);
    utcOffset[TimeZones.America_Caracas] = TimeZone.getTimeZone("America/Caracas").utcOffsetAt(currentTime);
    utcOffset[TimeZones.America_Cayenne] = TimeZone.getTimeZone("America/Cayenne").utcOffsetAt(currentTime);
    utcOffset[TimeZones.America_Chicago] = TimeZone.getTimeZone("America/Chicago").utcOffsetAt(currentTime);
    utcOffset[TimeZones.America_Chihuahua] = TimeZone.getTimeZone("America/Chihuahua").utcOffsetAt(currentTime);
    utcOffset[TimeZones.America_Cuiaba] = TimeZone.getTimeZone("America/Cuiaba").utcOffsetAt(currentTime);
    utcOffset[TimeZones.America_Denver] = TimeZone.getTimeZone("America/Denver").utcOffsetAt(currentTime);
    utcOffset[TimeZones.America_Godthab] = TimeZone.getTimeZone("America/Godthab").utcOffsetAt(currentTime);
    utcOffset[TimeZones.America_Guatemala] = TimeZone.getTimeZone("America/Guatemala").utcOffsetAt(currentTime);
    utcOffset[TimeZones.America_Halifax] = TimeZone.getTimeZone("America/Halifax").utcOffsetAt(currentTime);
    utcOffset[TimeZones.America_La_Paz] = TimeZone.getTimeZone("America/La_Paz").utcOffsetAt(currentTime);
    utcOffset[TimeZones.America_Los_Angeles] = TimeZone.getTimeZone("America/Los_Angeles").utcOffsetAt(currentTime);
    utcOffset[TimeZones.America_Mexico_City] = TimeZone.getTimeZone("America/Mexico_City").utcOffsetAt(currentTime);
    utcOffset[TimeZones.America_Montevideo] = TimeZone.getTimeZone("America/Montevideo").utcOffsetAt(currentTime);
    utcOffset[TimeZones.America_New_York] = TimeZone.getTimeZone("America/New_York").utcOffsetAt(currentTime);
    utcOffset[TimeZones.America_Phoenix] = TimeZone.getTimeZone("America/Phoenix").utcOffsetAt(currentTime);
    utcOffset[TimeZones.America_Regina] = TimeZone.getTimeZone("America/Regina").utcOffsetAt(currentTime);
    utcOffset[TimeZones.America_Santa_Isabel] = TimeZone.getTimeZone("America/Santa_Isabel").utcOffsetAt(currentTime);
    utcOffset[TimeZones.America_Santiago] = TimeZone.getTimeZone("America/Santiago").utcOffsetAt(currentTime);
    utcOffset[TimeZones.America_Sao_Paulo] = TimeZone.getTimeZone("America/Sao_Paulo").utcOffsetAt(currentTime);
    utcOffset[TimeZones.America_St_Johns] = TimeZone.getTimeZone("America/St_Johns").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Asia_Almaty] = TimeZone.getTimeZone("Asia/Almaty").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Asia_Amman] = TimeZone.getTimeZone("Asia/Amman").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Asia_Baghdad] = TimeZone.getTimeZone("Asia/Baghdad").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Asia_Baku] = TimeZone.getTimeZone("Asia/Baku").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Asia_Bangkok] = TimeZone.getTimeZone("Asia/Bangkok").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Asia_Beirut] = TimeZone.getTimeZone("Asia/Beirut").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Asia_Calcutta] = TimeZone.getTimeZone("Asia/Calcutta").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Asia_Colombo] = TimeZone.getTimeZone("Asia/Colombo").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Asia_Damascus] = TimeZone.getTimeZone("Asia/Damascus").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Asia_Dhaka] = TimeZone.getTimeZone("Asia/Dhaka").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Asia_Dubai] = TimeZone.getTimeZone("Asia/Dubai").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Asia_Irkutsk] = TimeZone.getTimeZone("Asia/Irkutsk").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Asia_Jerusalem] = TimeZone.getTimeZone("Asia/Jerusalem").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Asia_Kabul] = TimeZone.getTimeZone("Asia/Kabul").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Asia_Kamchatka] = TimeZone.getTimeZone("Asia/Kamchatka").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Asia_Karachi] = TimeZone.getTimeZone("Asia/Karachi").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Asia_Katmandu] = TimeZone.getTimeZone("Asia/Katmandu").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Asia_Krasnoyarsk] = TimeZone.getTimeZone("Asia/Krasnoyarsk").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Asia_Magadan] = TimeZone.getTimeZone("Asia/Magadan").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Asia_Novosibirsk] = TimeZone.getTimeZone("Asia/Novosibirsk").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Asia_Rangoon] = TimeZone.getTimeZone("Asia/Rangoon").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Asia_Riyadh] = TimeZone.getTimeZone("Asia/Riyadh").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Asia_Seoul] = TimeZone.getTimeZone("Asia/Seoul").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Asia_Shanghai] = TimeZone.getTimeZone("Asia/Shanghai").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Asia_Singapore] = TimeZone.getTimeZone("Asia/Singapore").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Asia_Taipei] = TimeZone.getTimeZone("Asia/Taipei").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Asia_Tashkent] = TimeZone.getTimeZone("Asia/Tashkent").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Asia_Tbilisi] = TimeZone.getTimeZone("Asia/Tbilisi").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Asia_Tehran] = TimeZone.getTimeZone("Asia/Tehran").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Asia_Tokyo] = TimeZone.getTimeZone("Asia/Tokyo").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Asia_Ulaanbaatar] = TimeZone.getTimeZone("Asia/Ulaanbaatar").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Asia_Vladivostok] = TimeZone.getTimeZone("Asia/Vladivostok").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Asia_Yakutsk] = TimeZone.getTimeZone("Asia/Yakutsk").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Asia_Yekaterinburg] = TimeZone.getTimeZone("Asia/Yekaterinburg").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Asia_Yerevan] = TimeZone.getTimeZone("Asia/Yerevan").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Atlantic_Azores] = TimeZone.getTimeZone("Atlantic/Azores").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Atlantic_Cape_Verde] = TimeZone.getTimeZone("Atlantic/Cape_Verde").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Atlantic_Reykjavik] = TimeZone.getTimeZone("Atlantic/Reykjavik").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Australia_Adelaide] = TimeZone.getTimeZone("Australia/Adelaide").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Australia_Brisbane] = TimeZone.getTimeZone("Australia/Brisbane").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Australia_Darwin] = TimeZone.getTimeZone("Australia/Darwin").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Australia_Hobart] = TimeZone.getTimeZone("Australia/Hobart").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Australia_Perth] = TimeZone.getTimeZone("Australia/Perth").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Australia_Sydney] = TimeZone.getTimeZone("Australia/Sydney").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Europe_Berlin] = TimeZone.getTimeZone("Europe/Berlin").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Europe_Budapest] = TimeZone.getTimeZone("Europe/Budapest").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Europe_Istanbul] = TimeZone.getTimeZone("Europe/Istanbul").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Europe_Kaliningrad] = TimeZone.getTimeZone("Europe/Kaliningrad").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Europe_Kiev] = TimeZone.getTimeZone("Europe/Kiev").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Europe_London] = TimeZone.getTimeZone("Europe/London").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Europe_Minsk] = TimeZone.getTimeZone("Europe/Minsk").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Europe_Moscow] = TimeZone.getTimeZone("Europe/Moscow").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Europe_Paris] = TimeZone.getTimeZone("Europe/Paris").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Europe_Warsaw] = TimeZone.getTimeZone("Europe/Warsaw").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Indian_Mauritius] = TimeZone.getTimeZone("Indian/Mauritius").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Pacific_Apia] = TimeZone.getTimeZone("Pacific/Apia").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Pacific_Auckland] = TimeZone.getTimeZone("Pacific/Auckland").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Pacific_Fiji] = TimeZone.getTimeZone("Pacific/Fiji").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Pacific_Guadalcanal] = TimeZone.getTimeZone("Pacific/Guadalcanal").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Pacific_Honolulu] = TimeZone.getTimeZone("Pacific/Honolulu").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Pacific_Port_Moresby] = TimeZone.getTimeZone("Pacific/Port_Moresby").utcOffsetAt(currentTime);
    utcOffset[TimeZones.Pacific_Tongatapu] = TimeZone.getTimeZone("Pacific/Tongatapu").utcOffsetAt(currentTime);
}