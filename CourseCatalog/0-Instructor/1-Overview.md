# Core Data + Threads

---

# Core Data is great for persisting an object graph to disk for late use

---

# Core Data is not great at making it easy to perform those saves off the main thread so your UI maintains responsiveness

---

# Threading is Hard

---

# Core Data is Hard

---
# Core Data + Threading = Mindsplode

---
# A Basic Core Data Stack

---

# Adding Threading Support

* Simply Adding a second MOC

---

#Different background MOC configurations 

---

#Parent/Child contexts

- background context (private)
- UI context (main)
- worker context (private)


