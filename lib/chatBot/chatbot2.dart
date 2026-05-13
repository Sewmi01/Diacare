import 'package:flutter/material.dart';

class Chatbot2 extends StatefulWidget {
  const Chatbot2({super.key});

  @override
  State<Chatbot2> createState() => _Chatbot2State();
}

class _Chatbot2State extends State<Chatbot2> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> messages = [];

  bool _isBotTyping = false;

  final Color darkBlue = const Color(0xFF0F2A5F);
  final Color lightBlue = const Color(0xFFEAF2FF);
  final Color green = const Color(0xFF24B47E);

  @override
  void initState() {
    super.initState();

    messages.add(
      ChatMessage(
        sender: MessageSender.bot,
        text:
            "Hello! I'm your DiaCare diabetes assistant. 😊\n"
            "You can ask about sugar level, diet, fruits, medicine, water, exercise, symptoms, or emergency.\n\n"
            "ආයුබෝවන්! මම DiaCare diabetes assistant. 😊\n"
            "ඔබට sugar level, diet, fruits, medicine, water, exercise, symptoms, emergency ගැන අහන්න පුළුවන්.",
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void sendMessage() {
    final String text = _controller.text.trim();

    if (text.isEmpty || _isBotTyping) return;

    setState(() {
      messages.add(
        ChatMessage(
          sender: MessageSender.user,
          text: text,
        ),
      );
      _isBotTyping = true;
    });

    _controller.clear();
    scrollToBottom();

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;

      final String reply = getBotReply(text);

      setState(() {
        messages.add(
          ChatMessage(
            sender: MessageSender.bot,
            text: reply,
          ),
        );
        _isBotTyping = false;
      });

      scrollToBottom();
    });
  }

  String normalizeMessage(String message) {
    return message.toLowerCase().trim();
  }

  bool containsAny(String message, List<String> words) {
    for (final word in words) {
      if (message.contains(word.toLowerCase())) {
        return true;
      }
    }
    return false;
  }

  String getBotReply(String userMessage) {
    final String message = normalizeMessage(userMessage);

    if (containsAny(message, [
      "hello",
      "hi",
      "hey",
      "good morning",
      "good evening",
      "ආයුබෝවන්",
      "හලෝ",
      "හායි",
      "සුබ උදෑසනක්",
      "සුබ සන්ධ්‍යාවක්",
    ])) {
      return bilingualReply(
        english:
            "Hello! 😊 I can help you with basic diabetes guidance such as sugar levels, diet, fruits, medicine reminders, water intake, exercise, symptoms, and emergency steps.",
        sinhala:
            "ආයුබෝවන්! 😊 මට ඔබට diabetes ගැන basic guidance දෙන්න පුළුවන්. Sugar level, diet, fruits, medicine reminders, water intake, exercise, symptoms, emergency steps ගැන අහන්න.",
      );
    }

    if (containsAny(message, [
      "high sugar",
      "sugar high",
      "high glucose",
      "glucose high",
      "hyperglycemia",
      "වැඩි sugar",
      "sugar වැඩි",
      "ග්ලූකෝස් වැඩි",
      "රුධිර සීනි වැඩි",
      "සීනි වැඩි",
    ])) {
      return bilingualReply(
        english:
            "⚠️ High blood sugar can be serious. Drink water, avoid sugary food/drinks, check your blood sugar again, and follow your doctor's advice. If your level stays very high or you feel vomiting, severe thirst, weakness, confusion, or breathing difficulty, contact a doctor immediately.",
        sinhala:
            "⚠️ Blood sugar වැඩි වීම අවදානම් විය හැක. වතුර බොන්න, පැණි/සීනි වැඩි ආහාර හා බීම වළක්වන්න, නැවත sugar level check කරන්න, doctor දුන් උපදෙස් අනුගමනය කරන්න. Sugar level එක දිගටම වැඩි නම්, වමනය, දැඩි තරහ, දුර්වලතාව, confusion, හුස්ම ගැනීමට අපහසු වීම වැනි ලක්ෂණ තියෙනවා නම් වහාම doctor කෙනෙක් හමුවන්න.",
      );
    }

    if (containsAny(message, [
      "low sugar",
      "sugar low",
      "low glucose",
      "glucose low",
      "hypoglycemia",
      "සීනි අඩු",
      "sugar අඩු",
      "රුධිර සීනි අඩු",
      "ග්ලූකෝස් අඩු",
    ])) {
      return bilingualReply(
        english:
            "⚠️ Low blood sugar needs quick action. If possible, check your glucose level. If it is below 70 mg/dL, take 15g of fast-acting carbohydrate such as glucose tablets, fruit juice, or sweets, wait 15 minutes, then check again. If the person is unconscious or cannot swallow, get emergency medical help.",
        sinhala:
            "⚠️ Blood sugar අඩු වීම ඉක්මනින් සැලකිල්ලට ගන්න ඕන. හැකි නම් glucose level check කරන්න. 70 mg/dL ට අඩු නම් glucose tablets, fruit juice, හෝ sweets වගේ ඉක්මනින් ක්‍රියාකරන carbohydrate 15g ගන්න. විනාඩි 15ක් ඉඳලා නැවත check කරන්න. පුද්ගලයා සිහිය නැති නම් හෝ ගිලීමට නොහැකි නම් වහාම emergency medical help ගන්න.",
      );
    }

    if (containsAny(message, [
      "sugar",
      "glucose",
      "blood sugar",
      "sugar level",
      "normal sugar",
      "fasting",
      "after meal",
      "රුධිර සීනි",
      "සීනි මට්ටම",
      "ග්ලූකෝස්",
      "normal sugar",
      "කෑමට පෙර",
      "කෑමෙන් පසු",
    ])) {
      return bilingualReply(
        english:
            "🩸 General blood sugar targets for many adults with diabetes are usually around 80–130 mg/dL before meals and below 180 mg/dL about 1–2 hours after starting a meal. Your personal target may be different, so follow your doctor's advice.",
        sinhala:
            "🩸 Diabetes තියෙන බොහෝ වැඩිහිටියන්ට සාමාන්‍ය blood sugar target එක කෑමට පෙර 80–130 mg/dL අතරත්, කෑම ආරම්භ කර පැය 1–2කට පසු 180 mg/dL ට අඩුවෙන්ත් වේ. නමුත් ඔබගේ personal target එක වෙනස් විය හැකි නිසා doctor උපදෙස් අනුගමනය කරන්න.",
      );
    }

    if (containsAny(message, [
      "diet",
      "food",
      "meal",
      "eat",
      "rice",
      "breakfast",
      "lunch",
      "dinner",
      "ආහාර",
      "කෑම",
      "ඩයට්",
      "බත්",
      "උදේ කෑම",
      "දවල් කෑම",
      "රාත්‍රී කෑම",
    ])) {
      return bilingualReply(
        english:
            "🥗 A diabetes-friendly meal should include more vegetables, enough protein, and controlled portions of rice or other carbohydrates. Try to reduce sugary drinks, sweets, deep-fried food, and large portions of white rice. Choose balanced meals and follow the diet plan recommended by your doctor or dietitian.",
        sinhala:
            "🥗 Diabetes-friendly meal එකකට එළවළු වැඩියෙන්, ප්‍රමාණවත් protein, සහ බත්/කාබෝහයිඩ්‍රේට් පාලිත ප්‍රමාණයකින් ඇතුළත් වීම හොඳයි. සීනි බීම, sweets, deep-fried food, සුදු බත් වැඩි ප්‍රමාණ වළක්වන්න. Doctor හෝ dietitian දුන් diet plan එක අනුගමනය කරන්න.",
      );
    }

    if (containsAny(message, [
      "fruit",
      "fruits",
      "apple",
      "banana",
      "mango",
      "guava",
      "papaya",
      "watermelon",
      "පළතුරු",
      "ඇපල්",
      "කෙසෙල්",
      "අඹ",
      "පේර",
      "පැපොල්",
      "කොමඩු",
    ])) {
      return bilingualReply(
        english:
            "🍎 Fruits can be healthy, but portion size matters. Better options include guava, apple, papaya, and berries in controlled amounts. Mango, banana, grapes, and very sweet fruits should be eaten carefully in small portions. Check the sugar content per 100g in the DiaCare fruit module before choosing.",
        sinhala:
            "🍎 පළතුරු හොඳයි, නමුත් portion size එක වැදගත්. පාලිත ප්‍රමාණයකින් පේර, ඇපල්, පැපොල් වගේ පළතුරු හොඳ තේරීමක්. අඹ, කෙසෙල්, grapes වගේ සීනි වැඩි පළතුරු කුඩා ප්‍රමාණයකින් පරිස්සමින් ගන්න. DiaCare fruit module එකෙන් 100gකට sugar content එක බලලා තෝරන්න.",
      );
    }

    if (containsAny(message, [
      "water",
      "drink water",
      "hydration",
      "thirst",
      "වතුර",
      "ජලය",
      "පිපාසය",
      "water reminder",
    ])) {
      return bilingualReply(
        english:
            "💧 Drinking enough water helps your body stay hydrated and supports diabetes management. Try to drink water regularly throughout the day. Avoid replacing water with sugary drinks or sweetened tea/coffee.",
        sinhala:
            "💧 දවස පුරා වතුර ප්‍රමාණවත් ලෙස බීම diabetes management එකට උපකාරී වේ. වතුර වෙනුවට පැණි බීම, සීනි දාපු තේ/කෝපි වැඩියෙන් බොන්න එපා. DiaCare water reminder එක use කරලා regular reminders දාගන්න.",
      );
    }

    if (containsAny(message, [
      "medicine",
      "tablet",
      "medication",
      "metformin",
      "dose",
      "missed dose",
      "pills",
      "බෙහෙත්",
      "medicine",
      "tablet",
      "මගහැරුනා",
      "dose",
      "ඖෂධ",
    ])) {
      return bilingualReply(
        english:
            "💊 Take your medicine exactly as prescribed by your doctor. Do not stop or change the dose by yourself. If you miss a dose, follow your doctor's instructions or contact a healthcare professional. You can use DiaCare reminders to avoid missed doses.",
        sinhala:
            "💊 Doctor දුන් විදිහටම බෙහෙත් ගන්න. ඔබම dose එක වෙනස් කරන්න හෝ බෙහෙත් නවත්වන්න එපා. Dose එකක් මගහැරුණොත් doctor දුන් උපදෙස් අනුගමනය කරන්න නැත්නම් healthcare professional කෙනෙක්ගෙන් අහන්න. Missed doses අඩු කරගන්න DiaCare reminders use කරන්න.",
      );
    }

    if (containsAny(message, [
      "insulin",
      "injection",
      "ඉන්සියුලින්",
      "insulin injection",
      "එන්නත්",
    ])) {
      return bilingualReply(
        english:
            "💉 Use insulin only as instructed by your doctor. Check the correct dose, time, and injection method. Do not skip insulin or change the dose without medical advice. If you feel shaky, sweaty, dizzy, or confused after insulin, check for low sugar.",
        sinhala:
            "💉 Insulin doctor කියපු විදිහටම use කරන්න. Correct dose, time, injection method හරියට බලන්න. Medical advice නැතුව insulin skip කරන්න හෝ dose වෙනස් කරන්න එපා. Insulin ගත්ත පසු වෙව්ලීම, දහඩිය, dizziness, confusion තියෙනවා නම් low sugar check කරන්න.",
      );
    }

    if (containsAny(message, [
      "exercise",
      "walk",
      "walking",
      "workout",
      "gym",
      "run",
      "ව්‍යායාම",
      "ඇවිදින්න",
      "walk",
      "දුවන්න",
    ])) {
      return bilingualReply(
        english:
            "🏃 Regular physical activity can help control blood sugar. A simple option is walking for about 30 minutes on most days, if your doctor says it is safe. Check sugar before heavy exercise if needed, and carry a small fast-acting carbohydrate in case sugar becomes low.",
        sinhala:
            "🏃 Regular exercise blood sugar control කරන්න උදව් වෙනවා. Doctor safe කියලා තියෙනවා නම් දවස් බොහොමයක විනාඩි 30ක් පමණ ඇවිදීම හොඳයි. Heavy exercise කිරීමට පෙර අවශ්‍ය නම් sugar check කරන්න. Low sugar වුණොත් ගන්න small fast-acting carbohydrate එකක් ළඟ තියාගන්න.",
      );
    }

    if (containsAny(message, [
      "symptom",
      "symptoms",
      "sign",
      "thirst",
      "urination",
      "tired",
      "blurred",
      "vision",
      "ලක්ෂණ",
      "පිපාසය",
      "මුත්‍රා",
      "තෙහෙට්ටුව",
      "දැක්ම",
      "blur",
    ])) {
      return bilingualReply(
        english:
            "⚠️ Common diabetes symptoms can include increased thirst, frequent urination, tiredness, blurred vision, slow wound healing, and unexpected weight loss. If you have these symptoms often, check your blood sugar and speak to a doctor.",
        sinhala:
            "⚠️ Diabetes ලක්ෂණ ලෙස පිපාසය වැඩි වීම, නිතර මුත්‍රා යාම, තෙහෙට්ටුව, දැක්ම blur වීම, තුවාල සුව වීම මන්දගාමී වීම, හදිසි බර අඩු වීම වැනි දේ පෙන්විය හැක. මේවා නිතර තිබේ නම් blood sugar check කර doctor කෙනෙක් හමුවන්න.",
      );
    }

    if (containsAny(message, [
      "emergency",
      "urgent",
      "danger",
      "faint",
      "unconscious",
      "chest pain",
      "breathing",
      "vomiting",
      "හදිසි",
      "අවදානම්",
      "සිහිය නැති",
      "හුස්ම",
      "වමනය",
      "පපුවේ වේදනාව",
    ])) {
      return bilingualReply(
        english:
            "🚨 Emergency warning: If the patient is unconscious, confused, having chest pain, breathing difficulty, repeated vomiting, severe weakness, or very high/very low sugar, seek urgent medical help immediately. This chatbot is not a replacement for a doctor.",
        sinhala:
            "🚨 හදිසි අවවාදය: රෝගියාට සිහිය නැති වීම, confusion, පපුවේ වේදනාව, හුස්ම ගැනීමට අපහසු වීම, නැවත නැවත වමනය, දැඩි දුර්වලතාව, sugar ඉතා වැඩි/ඉතා අඩු වීම තියෙනවා නම් වහාම urgent medical help ගන්න. මේ chatbot එක doctor කෙනෙක් වෙනුවට නොවේ.",
      );
    }

    if (containsAny(message, [
      "doctor",
      "consult",
      "appointment",
      "clinic",
      "hospital",
      "physician",
      "වෛද්‍ය",
      "doctor",
      "appointment",
      "clinic",
      "රෝහල",
    ])) {
      return bilingualReply(
        english:
            "👨‍⚕️ Regular doctor follow-up is important for diabetes care. Share your sugar readings, medicine details, diet changes, and symptoms with your doctor. DiaCare helps doctors review patient information more easily.",
        sinhala:
            "👨‍⚕️ Diabetes care සඳහා regular doctor follow-up වැදගත්. ඔබගේ sugar readings, medicine details, diet changes, symptoms doctor සමඟ share කරන්න. DiaCare මගින් doctorsට patient information පහසුවෙන් review කරන්න පුළුවන්.",
      );
    }

    if (containsAny(message, [
      "reminder",
      "alarm",
      "notification",
      "remember",
      "schedule",
      "මතක්",
      "reminder",
      "alarm",
      "notification",
      "schedule",
    ])) {
      return bilingualReply(
        english:
            "⏰ DiaCare reminders can help you remember medicine and water intake on time. Set reminders for each medicine separately and keep the schedule according to your doctor's prescription.",
        sinhala:
            "⏰ DiaCare reminders මගින් medicine සහ water intake මතක් කරගන්න පුළුවන්. එක් එක් බෙහෙතට වෙන වෙනම reminder set කරලා doctor prescription එක අනුව schedule එක තබාගන්න.",
      );
    }

    if (containsAny(message, [
      "thank",
      "thanks",
      "thank you",
      "ස්තුතියි",
      "බොහොම ස්තුතියි",
    ])) {
      return bilingualReply(
        english:
            "You're welcome! 😊 Keep monitoring your health and follow your doctor's advice.",
        sinhala:
            "ඔබව සාදරයෙන් පිළිගන්නවා! 😊 ඔබගේ health regularly monitor කරලා doctor උපදෙස් අනුගමනය කරන්න.",
      );
    }

    return bilingualReply(
      english:
          "🤖 I can answer basic questions about diabetes. Try asking about sugar level, high sugar, low sugar, diet, fruits, water, medicine, insulin, exercise, symptoms, reminders, or doctor consultation.",
      sinhala:
          "🤖 මට diabetes ගැන basic questions වලට උත්තර දෙන්න පුළුවන්. Sugar level, high sugar, low sugar, diet, fruits, water, medicine, insulin, exercise, symptoms, reminders, doctor consultation ගැන අහන්න.",
    );
  }

  String bilingualReply({
    required String english,
    required String sinhala,
  }) {
    return "$english\n\n$sinhala\n\n⚕️ Note / සටහන: This is general guidance only. Always follow your doctor's advice.";
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Widget buildMessage(ChatMessage msg) {
    final bool isUser = msg.sender == MessageSender.user;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isUser ? darkBlue : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isUser ? 18 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(
              color: isUser ? darkBlue : Colors.grey.shade200,
            ),
          ),
          child: Text(
            msg.text,
            style: TextStyle(
              color: isUser ? Colors.white : const Color(0xFF1A1A1A),
              fontSize: 14.5,
              height: 1.35,
            ),
          ),
        ),
      ),
    );
  }

  Widget typingIndicator() {
    if (!_isBotTyping) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Text(
            "Typing... / Type කරනවා...",
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget quickButtons() {
    final List<QuickOption> options = [
      QuickOption("Sugar Level", "Sugar level / සීනි මට්ටම"),
      QuickOption("High Sugar", "High sugar / සීනි වැඩි"),
      QuickOption("Low Sugar", "Low sugar / සීනි අඩු"),
      QuickOption("Diet", "Diet / ආහාර"),
      QuickOption("Fruits", "Fruits / පළතුරු"),
      QuickOption("Medicine", "Medicine / බෙහෙත්"),
      QuickOption("Water", "Water / වතුර"),
      QuickOption("Exercise", "Exercise / ව්‍යායාම"),
      QuickOption("Symptoms", "Symptoms / ලක්ෂණ"),
      QuickOption("Emergency", "Emergency / හදිසි"),
    ];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: options.length,
        itemBuilder: (context, index) {
          final option = options[index];

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              backgroundColor: Colors.white,
              side: BorderSide(color: green.withOpacity(0.4)),
              label: Text(
                option.label,
                style: TextStyle(
                  color: darkBlue,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
              ),
              onPressed: _isBotTyping
                  ? null
                  : () {
                      _controller.text = option.message;
                      sendMessage();
                    },
            ),
          );
        },
      ),
    );
  }

  Widget inputArea() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.send,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Ask about diabetes... / Diabetes ගැන අහන්න...",
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 13.5,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 24,
              backgroundColor: _isBotTyping ? Colors.grey : darkBlue,
              child: IconButton(
                icon: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                ),
                onPressed: _isBotTyping ? null : sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget headerCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            darkBlue,
            const Color(0xFF173E82),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: darkBlue.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(
              Icons.health_and_safety,
              color: Color(0xFF0F2A5F),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "DiaCare Assistant\nEnglish + Sinhala Diabetes Guidance",
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.5,
                fontWeight: FontWeight.bold,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBlue,
      appBar: AppBar(
        backgroundColor: darkBlue,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Diabetes Chatbot",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 8),
              itemCount: messages.length + 2,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return headerCard();
                }

                if (index == messages.length + 1) {
                  return typingIndicator();
                }

                return buildMessage(messages[index - 1]);
              },
            ),
          ),
          quickButtons(),
          inputArea(),
        ],
      ),
    );
  }
}

enum MessageSender {
  user,
  bot,
}

class ChatMessage {
  final MessageSender sender;
  final String text;

  ChatMessage({
    required this.sender,
    required this.text,
  });
}

class QuickOption {
  final String message;
  final String label;

  QuickOption(this.message, this.label);
}