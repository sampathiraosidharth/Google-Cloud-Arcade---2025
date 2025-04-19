# 🚀 Google Chat Bot - Apps Script | [GSP250 Lab Guide](https://www.cloudskillsboost.google/focuses/32756?parent=catalog)

## 🔐 Build Your Own Smart Chat Bot Using Google Apps Script

### 📽️ Solution Video 👉 [GSP250 Lab Guide]()

---

## ✅ Step-by-Step Lab Procedure

✅ **1. Creating a Chat App from Template**  
Let's start by creating a Google Chat app using a template:

1. Open the Google Apps Script editor using [this link](https://script.google.com/home/projects/create?template=hangoutsChat)
2. Rename your project to **Attendance Bot**:
   - Click on "Untitled project"
   - Enter "Attendance Bot" in the dialog
   - Click "Rename"
3. Replace the content in `Code.gs` with this starter code:

```javascript
/**
 * Responds to a MESSAGE event in Google Chat.
 *
 * @param {Object} event the event object from Google Chat
 */
function onMessage(event) {
  var name = "";

  if (event.space.type == "DM") {
    name = "You";
  } else {
    name = event.user.displayName;
  }
  var message = name + " said \"" + event.message.text + "\"";

  return { "text": message };
}

/**
 * Responds to an ADDED_TO_SPACE event in Google Chat.
 *
 * @param {Object} event the event object from Google Chat
 */
function onAddToSpace(event) {
  var message = "";

  if (event.space.singleUserBotDm) {
    message = "Thank you for adding me to a DM, " + event.user.displayName + "!";
  } else {
    message = "Thank you for adding me to " +
        (event.space.displayName ? event.space.displayName : "this chat");
  }

  if (event.message) {
    // Bot added through @mention.
    message = message + " and you said: \"" + event.message.text + "\"";
  }
  console.log('Attendance Bot added in ', event.space.name);
  return { "text": message };
}

/**
 * Responds to a REMOVED_FROM_SPACE event in Google Chat.
 *
 * @param {Object} event the event object from Google Chat
 */
function onRemoveFromSpace(event) {
  console.info("Bot removed from ",
      (event.space.name ? event.space.name : "this chat"));
}
```

4. Save your code

✅ **2. Publishing Your Chat Bot**  
Now let's configure and publish your bot:

1. Configure OAuth consent screen:
   - Go to [OAuth consent screen](https://console.cloud.google.com/auth/overview?)
   - Set "App name" to "Attendance Bot"
   - Choose your email ID as "User support email"
   - Select "Internal" for Audience
   - Add your email address in "Contact Information"
   - Enter your project number in "GCP Project number"

2. Configure Google Chat API:
   - Navigate to [Google Chat API Configuration](https://console.cloud.google.com/apis/api/chat.googleapis.com/hangouts-chat?)
   - Configure these settings:
     - App name: Attendance Bot
     - Avatar URL: https://goo.gl/kv2ENA
     - Description: Apps Script lab bot
     - Functionality: Select "Receive 1:1 messages" and "Join spaces and group conversations"
     - Connection settings: Check "Apps Script project" and paste your Head Deployment ID
     - Visibility: Your user email address
   - Change "App Status" to "LIVE – available to users"

3. Test your bot:
   - Open [Google Chat](https://chat.google.com/)
   - Click "Start a chat"
   - Search for "Attendance Bot"
   - Select your bot and click "Start chat"

✅ **3. Creating Card-Formatted Responses**  
Let's enhance our bot with card-formatted responses:

1. Replace your entire `Code.gs` with this improved version:

```javascript
var DEFAULT_IMAGE_URL = 'https://goo.gl/bMqzYS';
var HEADER = {
  header: {
    title : 'Attendance Bot',
    subtitle : 'Log your vacation time',
    imageUrl : DEFAULT_IMAGE_URL
  }
};

/**
 * Creates a card-formatted response.
 * @param {object} widgets the UI components to send
 * @return {object} JSON-formatted response
 */
function createCardResponse(widgets) {
  return {
    cards: [HEADER, {
      sections: [{
        widgets: widgets
      }]
    }]
  };
}

/**
 * Responds to a MESSAGE event triggered
 * in Google Chat.
 *
 * @param event the event object from Google Chat
 * @return JSON-formatted response
 */
function onMessage(event) {
  var userMessage = event.message.text;

  var widgets = [{
    "textParagraph": {
      "text": "You said: " + userMessage
    }
  }];

  console.log('You said:', userMessage);

  return createCardResponse(widgets);
}

/**
 * Responds to an ADDED_TO_SPACE event in Google Chat.
 *
 * @param {Object} event the event object from Google Chat
 */
function onAddToSpace(event) {
  var message = "";

  if (event.space.singleUserBotDm) {
    message = "Thank you for adding me to a DM, " + event.user.displayName + "!";
  } else {
    message = "Thank you for adding me to " +
        (event.space.displayName ? event.space.displayName : "this chat");
  }

  if (event.message) {
    // Bot added through @mention.
    message = message + " and you said: \"" + event.message.text + "\"";
  }
  console.log('Attendance Bot added in ', event.space.name);
  return { "text": message };
}

/**
 * Responds to a REMOVED_FROM_SPACE event in Google Chat.
 *
 * @param {Object} event the event object from Google Chat
 */
function onRemoveFromSpace(event) {
  console.info("Bot removed from ",
      (event.space.name ? event.space.name : "this chat"));
}
```

2. Save and test your bot by sending a message like "Hello"

✅ **4. Adding Interactive Features with Button Clicks**  
Now let's make our bot interactive with buttons:

1. Replace your entire `Code.gs` with this advanced version:

```javascript
var DEFAULT_IMAGE_URL = 'https://goo.gl/bMqzYS';
var HEADER = {
  header: {
    title : 'Attendance Bot',
    subtitle : 'Log your vacation time',
    imageUrl : DEFAULT_IMAGE_URL
  }
};

/**
 * Creates a card-formatted response.
 * @param {object} widgets the UI components to send
 * @return {object} JSON-formatted response
 */
function createCardResponse(widgets) {
  return {
    cards: [HEADER, {
      sections: [{
        widgets: widgets
      }]
    }]
  };
}

var REASON = {
  SICK: 'Out sick',
  OTHER: 'Out of office'
};
/**
 * Responds to a MESSAGE event triggered in Google Chat.
 * @param {object} event the event object from Google Chat
 * @return {object} JSON-formatted response
 */
function onMessage(event) {
  console.info(event);
  var reason = REASON.OTHER;
  var name = event.user.displayName;
  var userMessage = event.message.text;

  // If the user said that they were 'sick', adjust the image in the
  // header sent in response.
  if (userMessage.indexOf('sick') > -1) {
    // Hospital material icon
    HEADER.header.imageUrl = 'https://goo.gl/mnZ37b';
    reason = REASON.SICK;
  } else if (userMessage.indexOf('vacation') > -1) {
    // Spa material icon
    HEADER.header.imageUrl = 'https://goo.gl/EbgHuc';
  }

  var widgets = [{
    textParagraph: {
      text: 'Hello, ' + name + '.<br>Are you taking time off today?'
    }
  }, {
    buttons: [{
      textButton: {
        text: 'Set vacation in Gmail',
        onClick: {
          action: {
            actionMethodName: 'turnOnAutoResponder',
            parameters: [{
              key: 'reason',
              value: reason
            }]
          }
        }
      }
    }, {
      textButton: {
        text: 'Block out day in Calendar',
        onClick: {
          action: {
            actionMethodName: 'blockOutCalendar',
            parameters: [{
              key: 'reason',
              value: reason
            }]
          }
        }
      }
    }]
  }];
  return createCardResponse(widgets);
}

/**
 * Responds to an ADDED_TO_SPACE event in Google Chat.
 *
 * @param {Object} event the event object from Google Chat
 */
function onAddToSpace(event) {
  var message = "";

  if (event.space.singleUserBotDm) {
    message = "Thank you for adding me to a DM, " + event.user.displayName + "!";
  } else {
    message = "Thank you for adding me to " +
        (event.space.displayName ? event.space.displayName : "this chat");
  }

  if (event.message) {
    // Bot added through @mention.
    message = message + " and you said: \"" + event.message.text + "\"";
  }
  console.log('Attendance Bot added in ', event.space.name);
  return { "text": message };
}

/**
 * Responds to a REMOVED_FROM_SPACE event in Google Chat.
 *
 * @param {Object} event the event object from Google Chat
 */
function onRemoveFromSpace(event) {
  console.info("Bot removed from ",
      (event.space.name ? event.space.name : "this chat"));
}

/**
 * Responds to a CARD_CLICKED event triggered in Google Chat.
 * @param {object} event the event object from Google Chat
 * @return {object} JSON-formatted response
 * @see https://developers.google.com/chat/reference/message-formats/events
 */
function onCardClick(event) {
  console.info(event);
  var message = '';
  var reason = event.action.parameters[0].value;
  if (event.action.actionMethodName == 'turnOnAutoResponder') {
    turnOnAutoResponder(reason);
    message = 'Turned on vacation settings.';
  } else if (event.action.actionMethodName == 'blockOutCalendar') {
    blockOutCalendar(reason);
    message = 'Blocked out your calendar for the day.';
  } else {
    message = "I'm sorry; I'm not sure which button you clicked.";
  }
  return { text: message };
}

var ONE_DAY_MILLIS = 24 * 60 * 60 * 1000;
/**
 * Turns on the user's vacation response for today in Gmail.
 * @param {string} reason the reason for vacation, either REASON.SICK or REASON.OTHER
 */
function turnOnAutoResponder(reason) {
  var currentTime = (new Date()).getTime();
  Gmail.Users.Settings.updateVacation({
    enableAutoReply: true,
    responseSubject: reason,
    responseBodyHtml: "I'm out of the office today; will be back on the next business day.<br><br><i>Created by Attendance Bot!</i>",
    restrictToContacts: true,
    restrictToDomain: true,
    startTime: currentTime,
    endTime: currentTime + ONE_DAY_MILLIS
  }, 'me');
}

/**
 * Places an all-day meeting on the user's Calendar.
 * @param {string} reason the reason for vacation, either REASON.SICK or REASON.OTHER
 */
function blockOutCalendar(reason) {
  CalendarApp.createAllDayEvent(reason, new Date(), new Date(Date.now() + ONE_DAY_MILLIS));
}
```

2. Add the Gmail API service:
   - Click "Add a service" in the left-side menu
   - Select "Gmail API" from the list
   - Click "Add"

3. Test your interactive bot:
   - Return to your chat with the bot
   - Type "I'm sick"
   - Try using the buttons to set vacation responders and block your calendar

---

## 🧪 Optional Experimentation
Try extending your chat bot with these ideas:

1. Add more response options based on different keywords
2. Create custom calendar events with different durations
3. Add image responses based on more specific user messages
4. Explore other Google services you can integrate with your bot
5. Check your bot's console logs to see how the interactions work

---

# 🎯 Mission Accomplished!
You've successfully built an interactive Google Chat Bot using Apps Script! 🚀  
Your bot can now help manage vacation time, set auto-responders, and update your calendar automatically! 🌩️

---

## 📋 Lab Success Checklist
- [x] Created a Chat App from a template
- [x] Published and configured the bot
- [x] Implemented card-formatted responses
- [x] Added interactive buttons and actions
- [x] Connected with Gmail API
- [x] Tested bot interactions

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