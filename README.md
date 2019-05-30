# Harmonic fields

This application is intended to be used as a webhook to Dialogflow.

It will receive a POST request and then will find which harmonic field the chord received belongs or will find the cipher for the song received.

## Find which harmonic field the chord belongs

The application expects the following parameters when trying to find which harmonic field the chord belongs:

```
{
  "body": {
    "session": "example",
    "queryResult": {
      "intent": {
        "displayName": "acorde"
      },
      "parameters": {
        "acorde": "example"
      }
    }
  }
}
```
