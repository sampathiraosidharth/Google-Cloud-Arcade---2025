# 🔍 Natural Language API from Google Docs | GSP126 Lab Guide

## 🚀 Analyze Text Sentiment with Google's Natural Language API — Step-by-Step!

### 📽️ Solution Video 👉 [Coming Soon – Stay Tuned!](#)

---

## 🛠️ Step-by-Step Lab Procedure

### ✅ Step 1: Enable the Natural Language API

1. In Google Cloud Console, go to **Navigation menu > APIs & Services > Library**
2. Search for **Cloud Natural Language API**
3. Click on the API to enable it (or confirm it's already enabled)

---

### ✅ Step 2: Get an API Key

1. Go to **Navigation menu > APIs & Services > Credentials**
2. Click **Create credentials** and select **API key**
3. Copy your API key to use later
4. Click **Close**

---

### ✅ Step 3: Set up your Google Doc

1. Create a new Google Doc
2. From the document, select **Extensions > Apps Script**
3. Delete any existing code and paste the provided script:

```javascript
/**
* @OnlyCurrentDoc
*/

function onOpen() {
  var ui = DocumentApp.getUi();
  ui.createMenu('Natural Language Tools')
    .addItem('Mark Sentiment', 'markSentiment')
    .addToUi();
}

function markSentiment() {
  var POSITIVE_COLOR = '#00ff00';  // Colors for sentiments
  var NEGATIVE_COLOR = '#ff0000';
  var NEUTRAL_COLOR = '#ffff00';
  var NEGATIVE_CUTOFF = -0.2;   // Thresholds for sentiments
  var POSITIVE_CUTOFF = 0.2;

  var selection = DocumentApp.getActiveDocument().getSelection();
  if (selection) {
    var string = getSelectedText();

    var sentiment = retrieveSentiment(string);

    // Select the appropriate color
    var color = NEUTRAL_COLOR;
    if (sentiment <= NEGATIVE_CUTOFF) {
      color = NEGATIVE_COLOR;
    }
    if (sentiment >= POSITIVE_CUTOFF) {
      color = POSITIVE_COLOR;
    }

    // Highlight the text
    var elements = selection.getSelectedElements();
    for (var i = 0; i < elements.length; i++) {
      if (elements[i].isPartial()) {
        var element = elements[i].getElement().editAsText();
        var startIndex = elements[i].getStartOffset();
        var endIndex = elements[i].getEndOffsetInclusive();
        element.setBackgroundColor(startIndex, endIndex, color);

      } else {
        var element = elements[i].getElement().editAsText();
        foundText = elements[i].getElement().editAsText();
        foundText.setBackgroundColor(color);
      }
    }
  }
}

function getSelectedText() {
  var selection = DocumentApp.getActiveDocument().getSelection();
  var string = "";
  if (selection) {
    var elements = selection.getSelectedElements();

    for (var i = 0; i < elements.length; i++) {
      if (elements[i].isPartial()) {
        var element = elements[i].getElement().asText();
        var startIndex = elements[i].getStartOffset();
        var endIndex = elements[i].getEndOffsetInclusive() + 1;
        var text = element.getText().substring(startIndex, endIndex);
        string = string + text;

      } else {
        var element = elements[i].getElement();
        // Only translate elements that can be edited as text; skip
        // images and other non-text elements.
        if (element.editAsText) {
          string = string + element.asText().getText();
        }
      }
    }
  }
  return string;
}

function retrieveSentiment (line) {
  // TODO:  Call the Natural Language API with the line given
  // and return the sentiment value.
  return 0.0;
}
```

4. Click **Save project** to Drive
5. Return to your document and add sample text
6. Reload the document to see the new **Natural Language Tools** menu
7. Select text and choose **Mark Sentiment**
   - Authorize the script when prompted
   - Selected text will be highlighted yellow (neutral)

---

### ✅ Step 4: Call the Natural Language API

1. Return to **Extensions > Apps Script**
2. Replace the `retrieveSentiment` function with the complete version:

```javascript
function retrieveSentiment (line) {
  var apiKey = "YOUR_API_KEY"; // Replace with your actual API key
  var apiEndpoint = "https://language.googleapis.com/v1/documents:analyzeSentiment?key=" + apiKey;

  // Create a structure with the text, its language, its type,
  // and its encoding
  var docDetails = {
    language: 'en-us',
    type: 'PLAIN_TEXT',
    content: line
  };

  var nlData = {
    document: docDetails,
    encodingType: 'UTF8'
  };

  // Package all of the options and the data together for the call
  var nlOptions = {
    method : 'post',
    contentType: 'application/json',
    payload : JSON.stringify(nlData)
  };

  // And make the call
  var response = UrlFetchApp.fetch(apiEndpoint, nlOptions);

  var data = JSON.parse(response);

  var sentiment = 0.0;
  // Ensure all pieces were in the returned value
  if (data && data.documentSentiment
          && data.documentSentiment.score){
     sentiment = data.documentSentiment.score;
  }

  return sentiment;
}
```

3. Replace `YOUR_API_KEY` with your actual API key from Step 2
4. Click **Save** and return to your document
5. Test the functionality:
   - Select text and choose **Mark Sentiment**
   - Text will now be highlighted according to sentiment:
     - 🟢 **Green** for positive (score ≥ 0.2)
     - 🔴 **Red** for negative (score ≤ -0.2)
     - 🟡 **Yellow** for neutral (-0.2 < score < 0.2)

---

## 🧪 Optional Experimentation

- Try typing and analyzing your own sentences
- Compare sentiment analysis results for different phrases:
  - "I'm mad" vs "I'm happy"
  - "I'm happy. I'm happy. I'm sad." vs "I'm happy. I'm sad. I'm sad."
- See how adding more positive or negative statements affects the overall sentiment score

---

## 🎯 Lab Success Checklist

- [x] Natural Language API enabled
- [x] API key created and implemented
- [x] Google Doc setup with custom menu
- [x] Sentiment analysis function implemented
- [x] Text highlights correctly based on sentiment

---

## 🔗 Let's Connect and Grow Together

Hi, I'm **Sidharth**, passionate about helping students and developers!  
Stay connected for more such 🔥 labs, walkthroughs, and exclusive guides:

- 🔗 [LinkedIn](https://www.linkedin.com/in/sampathi-sidharth/)
- 📸 [Instagram](https://www.instagram.com/sampathi_rao_sidharth/)
- 📺 [YouTube – QuickPySidharth](https://www.youtube.com/@QuickPySidharth)

---

### 💡 Follow [QuickPySidharth](https://www.youtube.com/@QuickPySidharth) – For Weekly Dev Shortcuts & Deep Dives!

From GCP labs to automation tricks — crisp content, no fluff.  
**Subscribe now, thank yourself later.** ✅