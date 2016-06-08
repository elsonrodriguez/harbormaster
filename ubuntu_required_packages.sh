mkdir -p /mirror/
cp ubuntu/seeds /mirror/
germinate -d xenial,xenial-updates  -a amd64 -c universe --no-installer   -s seeds -S file:///mirror/
