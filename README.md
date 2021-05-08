# Parser
## Description
An API that can detect the presence of passive voice in a given text, through the use of regular expressions.

This API is part of my disseration on *Aiding the use of active voice through an all-purpose text analysis framework.*

## Endpoints
```
post: /analyse
```
Receives a *text* paramter, returns an array of JSON objects in the following format:
```
{
                phrase: "The ball was kicked by James",
                explanation: 'This phrase may be written in passive voice.',
                suggestion: 'Consider revising',
                substituion: false
}
```
The substitution field is used by the response recipient to determine whether a remidial phrase has been offered or not.

---
```
get: /name
```
Returns "Passive voice detector"
Used by the [Grammar Services Repository](https://github.com/Philiplewis35/grammar_checker_rails)

---
```
get: /description
```
Returns "Detects passive voice"
Used by the [Grammar Services Repository](https://github.com/Philiplewis35/grammar_checker_rails)
