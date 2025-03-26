# groq

# 📱 Quiz App using GROQ.com LLM APIs

## 🎯 Objective
This is a mobile quiz application built using Flutter that dynamically generates quiz questions using the GROQ.com LLM APIs. The app does not require a backend, as questions are generated on the fly via API requests.

---

## 🔧 Features
- **User Name Input:** After the splash screen, users are asked to enter their name before proceeding to the home screen.
- **Category & Difficulty Selection:**
  - Users can tap on a category to select a difficulty level from a dialog.
  - Based on the selected difficulty, the app fetches questions dynamically.
- **Dynamic Quiz Generation:** Fetches quiz questions using GROQ.com LLM APIs.
- **Multiple-Choice Questions:** Each question has 4 options, with a clearly marked correct answer.
- **Interactive UI:** Users select an answer and receive immediate feedback.
- **Score Tracking:** Keeps track of correct answers and calculates the final score.
- **Best Score Record:** Displays the best all-time score on the home page.
- **Recent Quiz History:** The home page lists the last 5 quizzes taken.
- **Retry Feature:** Allows users to regenerate a new quiz.
- **Local Storage:** Uses SharedPreferences to store past scores and best scores.
- **No State Management Library Used:** Managed state using setState due to the project's small scale.

---

## 📱 App Screens
### 1️⃣ Splash & Welcome Screen
- Displays a splash screen upon launching the app.
- After the splash screen, the user is prompted to enter their name before proceeding to the home screen.

### 2️⃣ Home Screen
- Displays a **Start Quiz** button.
- Allows users to select a category.
- **On tapping a category, a dialog appears to select difficulty level.**
- Displays **Best Score of All Time**.
- Shows the **list of the last 5 quizzes taken**.

### 3️⃣ Quiz Screen
- Displays one question at a time.
- User selects an answer and gets immediate feedback (correct/incorrect).
- Tracks and updates the user's score dynamically.

### 4️⃣ Result Screen
- Displays the total correct answers and percentage score.
- Offers a **Retry** button to fetch new questions.

---

## ⚙️ Tech Stack
- **Frontend:** Flutter
- **Networking:** Dio for API calls
- **Local Storage:** SharedPreferences

---

## 🚀 Installation & Setup
### Prerequisites
- Flutter SDK installed ([Install Flutter](https://flutter.dev/docs/get-started/install))
- Android Studio or VS Code setup for Flutter development
- GROQ.com API key (sign up at [GROQ.com](https://www.groq.com/))

### Steps
1. **Clone the repository:**
   ```sh
   git clone https://github.com/yourusername/quiz-app.git
   ```
2. **Navigate to the project directory:**
   ```sh
   cd qroq
   ```
3. **Install dependencies:**
   ```sh
   flutter pub get
   ```
4. **Configure API Key:**
   - go to qroq.com and create your api key and replace in api.dart screen

5. **Run the app:**
   ```sh
   flutter run
   ```

---

## 🛠 API Usage
The app sends a request to GROQ.com’s LLM APIs using the following prompt:
```json
{
  "prompt": "Generate 5 random multiple-choice questions on general knowledge. Each should have a question, 4 options, and the correct answer clearly marked. Return only valid JSON.",
  "model": "llama3-8b-8192"
}
```
### Example Response
```json
{
  "questions": [
    {
      "question": "What is the capital of France?",
      "options": ["Berlin", "Madrid", "Paris", "Rome"],
      "answer": "Paris"
    }
  ]
}
```

---

## 🧠 Bonus Features (Optional)
- **Timer per question**
- **Difficulty selection via dialog**
- **Category-based question generation**

---

## 📦 Repository Structure
```
quiz-app/
│── lib/
│   ├── common/
│   │   ├── preferences.dart  # Handles local storage
│   │   ├── common_functions.dart  # Common utility functions
│   ├── constant/
│   │   ├── constants.dart  # Stores constant values
│   ├── core/
│   │   ├── api_service.dart  # Handles API calls
│   ├── presentation/
│   │   ├── home/
│   │   │   ├── data/
│   │   │   │   ├── model/
│   │   │   │   ├── repository/
│   │   │   ├── logic/
│   │   │   ├── screen/
│   │   │   ├── widget/
│   │   ├── quiz/
│   │   │   ├── data/
│   │   │   │   ├── model/
│   │   │   │   ├── repository/
│   │   │   ├── logic/
│   │   │   ├── screen/
│   │   │   ├── widget/
│   │   ├── result/
│   │   │   ├── data/
│   │   │   │   ├── model/
│   │   │   │   ├── repository/
│   │   │   ├── logic/
│   │   │   ├── screen/
│   │   │   ├── widget/
│   │   ├── welcome/
│   │   │   ├── data/
│   │   │   │   ├── model/
│   │   │   │   ├── repository/
│   │   │   ├── logic/
│   │   │   ├── screen/
│   │   │   ├── widget/
│── pubspec.yaml  # Dependencies
│── README.md  # Documentation
```

---

## 📜 License
This project is licensed under the MIT License.

---

## 🙌 Acknowledgments
- **GROQ.com** for providing LLM APIs
- **Dio** for API networking
- **Flutter Community** for their support

---

## ✨ Contributions
Feel free to fork this repository, create issues, and submit pull requests. Feedback and contributions are welcome!


