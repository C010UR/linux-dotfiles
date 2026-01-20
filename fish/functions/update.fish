function update
  yay -Suy --answerclean None --answerdiff None
  yay -S $(yay -Qoq /usr/lib/python3.14) --answerclean All --answerdiff None
  yay -S python-materialyoucolor --answerclean All --answerdiff None
  spicetify update
end
