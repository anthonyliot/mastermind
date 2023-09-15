#! /bin/sh

#fonction lancant la boucle du jeu mastermind
function MasterMind(){
	clear
	reponse="y"
	while [ "$reponse" == "y" ]; do
		Init
		CodeSecret
		TapeTonCode
		echo "Do you want to play again ? (y/n)"
		read reponse
	done
	clear
	return 1 # sort du jeu
}

#Permet de creer un tableau de 4 couleurs aleatoirement, les 4 couleurs seront distinctes.
function CodeSecret() {
	x=01234
	for((i=4;i>=0;i--));do
		((r=RANDOM%i+1))
		v=${x:r-1:1}
		case $v in
			0)
				couleurs="g"
				TabCode
				;;
			1)
				couleurs="b"
				TabCode
				;;
			2)
				couleurs="y"
				TabCode
				;;
			3)
	            couleurs="r"
				TabCode
				;;
			4)
	            couleurs="p"
				TabCode
				;;
		esac

		# on supprime la couleur choisie pour ne pas la reprendre
		x=${x:0:r-1}${x:r}
	done
}

#cette fonction recupere la couleur puis verifie si elle a deja ete utilise
#si elle n'a pas ete utilise alors elle est entre dans le tableau solution
function TabCode() {
	#augmente le tableau de la nouvelle couleur
	solution[$iter]="$couleurs"
	iter=$(($iter+1))
}

#permet au joueur de taper un code
function TapeTonCode(){
	clear
	nbessai=0
	#debut de la boucle qui correspond au nombre d'essai
	while [ $nbessai -lt 11 ]; do
		tput cup 0 0	
		echo "                                                                               "
		tput cup 0 0
		echo "Enter 4 colors ( Purple, Blue, Green, Red and Yellow ) :"
		read listecouleur
		#apres lecture des couleurs on verifie qu'il y a bien que 4 couleurs
		if ( [ `echo -n $listecouleur | wc -m` -eq 4 ] ) ;then
			a=$listecouleur
			#cette boucle "for" cree un tableau essai des 4 couleurs
			for i in $(seq 1 4); do
				essai[$i]=${a:$i-1:1}
			done
			#verifie que le joueur a bien utilise les 5 couleurs autorise V ert,B leu,J aune,R ouge,M agenta
			if (( [ ${essai[1]} == "g" ] ||
				 [ ${essai[1]} == "b" ] ||\
				 [ ${essai[1]} == "y" ] ||\
				 [ ${essai[1]} == "r" ] ||\
				 [ ${essai[1]} == "p" ] ) &&\
			   ( [ ${essai[2]} == "g" ] ||\
				 [ ${essai[2]} == "b" ] ||\
				 [ ${essai[2]} == "y" ] ||\
				 [ ${essai[2]} == "r" ] ||\
				 [ ${essai[2]} == "p" ] ) &&\
			   ( [ ${essai[3]} == "g" ] ||\
				 [ ${essai[3]} == "b" ] ||\
				 [ ${essai[3]} == "y" ] ||\
				 [ ${essai[3]} == "r" ] ||\
				 [ ${essai[3]} == "p" ] ) &&\
			   ( [ ${essai[4]} == "g" ] ||\
				 [ ${essai[4]} == "b" ] ||\
				 [ ${essai[4]} == "y" ] ||\
				 [ ${essai[4]} == "r" ] ||\
				 [ ${essai[4]} == "p" ] )) ; then
				#affiche les 4 couleurs taper par le joueur
				ligne=$(($nbessai+2))
				colonne=0
				AfficheCouleur
				#efface les lettres entre par le joueur
				tput cup 1 0
				echo "                                              "
				ligne=$(($ligne+1))
				#permet de dire le nombre de couleur bien ou mal place
				Verification		
				nbessai=$(($nbessai+1))
			else
				tput cup 0 0	
			    echo "You must enter 4 colors different from green, blue, yellow, red and purple"
				sleep 2
				tput cup 1 0
				echo "                                              "
			fi
		else
			tput cup 0 0
			echo "You must enter exactly 4 colors from green, blue, yellow, red and purple"
			sleep 2
			tput cup 1 0
			echo "                                              "
		fi	
	done
}

#cette fonction sort un background de la couleur voulu
function AfficheCouleur(){
	for i in $(seq 1 4); do
		tput cup $(($ligne+1)) $(($colonne + $i*3 - 3))
		if [ ${essai[$i]} == "g" ] ; then
			echo -ne "\033[42m";echo "  "
		fi
		if [ ${essai[$i]} == "b" ] ; then
			echo -ne "\033[44m";echo "  "
		fi
		if [ ${essai[$i]} == "p" ] ; then
			echo -ne "\033[45m";echo "  "
		fi
		if [ ${essai[$i]} == "y" ] ; then
			echo -ne "\033[43m";echo "  "
		fi
		if [ ${essai[$i]} == "r" ] ; then
			echo -ne "\033[41m";echo "  "
		fi
		echo -ne "\033[0m";echo ""	
	done
}

#verifie que les couleurs sont bien placer ou non.
function Verification(){
	place=0
	non_place=0
	
	#Il est nécessaire de ne pas compter plusieurs fois un même 
	#emplacement dans les décalés ou à la fois comme correct, puis 
	#décalé. Le tableau suivant sert à savoir si un emplacement est 
	#déja compté.
	for i in $(seq 1 4); do
		marques[$i]=0
	done

	#calcul le nombre de couleur bien et mal placé
	for i in $(seq 1 4); do
		for j in $(seq 1 4); do
			if [ "${essai[$j]}" == "${solution[$i]}" ]; then
				if [ "$i" == "$j" ]; then
					place=$(($place +1))
					if [ "${marques[$i]}" == 1 ];then
						non_place=$(($non_place -1))
					else
						marques[$i]=1;
					fi
				else
					if [ "${marques[$i]}" == 0 ]; then
						non_place=$(($non_place +1))
						marques[$i]=1;
					fi
				fi
			fi
		done
	done	

	correct_place=$place
	for i in $(seq 1 4); do
		if [ $place -gt 0 ]; then
			tput cup $(($ligne)) $(($i*2+20))
			echo -ne "\033[1;31m";echo "."
			place=$(($place -1))
		elif [ $non_place -gt 0 ]; then
			tput cup $(($ligne)) $(($i*2+20))
			echo -ne "\033[1;36m";echo "."
			non_place=$(($non_place -1))
		fi
	done

	echo -ne "\033[0m";echo ""
	
	#fin du jeu : si les 4 sont placés  gagné, ou si les 10 essai sont epuisé perdu	
	if [ "$correct_place" == 4 ]; then
		clear           
		echo "__        _____ _   _  "
		echo "\ \      / |_ _| \ | | "
		echo " \ \ /\ / / | ||  \| | "
		echo "  \ V  V /  | || |\  | "
		echo "   \_/\_/  |___|_| \_| "
		echo "                       "
		sleep 2
		nbessai=10
	elif [ "$nbessai" == 10 ]; then
		clear
		echo " _     ___  ____ _____ "
		echo "| |   / _ \/ ___|_   _|"
		echo "| |  | | | \___ \ | |  "
		echo "| |__| |_| |___) || |  "
		echo "|_____\___/|____/ |_|  "
		echo "                       "
		for i in $(seq 1 4); do
			essai[$i]=${solution[$i]}
		done
		echo "You lost, the correct respomse was :"
		ligne=9
		colonne=27
		AfficheCouleur
		sleep 2
		nbessai=10
	else 		
		tput cup $ligne  40
		echo "+ $((10-$nbessai)) try left"
	fi
}

#cette fonction ammene l'intro du jeu avec ces regles
function Init(){
	clear
	tput cup 3 0	                                                         
	echo " __  __    _    ____ _____ _____ ____  __  __ ___ _   _ ____  "
	echo "|  \/  |  / \  / ___|_   _| ____|  _ \|  \/  |_ _| \ | |  _ \ "
	echo "| |\/| | / _ \ \___ \ | | |  _| | |_) | |\/| || ||  \| | | | |"
	echo "| |  | |/ ___ \ ___) || | | |___|  _ <| |  | || || |\  | |_| |"
	echo "|_|  |_/_/   \_|____/ |_| |_____|_| \_|_|  |_|___|_| \_|____/ "
	echo ""
	echo ""
	echo "                   by Liot Anthony <anthony.liot@gmail.com>"
	sleep 1
	clear
	tput cup 4 30
	echo "Rules of the game:"
	tput cup 7 0
	echo "The computer picks a sequence of colors. The number of colors is the code length. The default code length is 4 using this list of colors (purple, blue, green, red and yellow)."
	echo "The objective of the game is to guess the exact positions of the colors in the computer's sequence."
	echo "For each color in your guess that is in the correct color and correct position in the code sequence, the computer display a small red color on the right side of the current guess."
	echo "For each color in your guess that is in the correct color but in the WRONG position, the computer display a small cyan color on the right side of the current guess."
	echo "You win the game when you manage to guess all the colors in the code sequence and when they all in the right position."
	echo "You lose the game if you use all attempts without guessing the computer code sequence."
	echo "You have 10 attempts."
	echo ""
	echo "To enter a color, type the first letter of the color."
	echo "(ex: bgry pour blue, green, red and yellow)."
	echo ""
	echo "Good Luck !"
	tput cup 22 30
	echo "[Press Enter to continue]"
	read
}


MasterMind
