#include("/Users/thomaslapierre/Desktop/Licence Informatique/Semestre 6/Recherche opérationnelle/Projet/OptimisationTourneeDrones/exo4.jl")
#creationDistancier("/Users/thomaslapierre/Desktop/Licence Informatique/Semestre 6/Recherche opérationnelle/Projet/OptimisationTourneeDrones/A/VRPA10.dat")
#creationDistancier("/Users/thomaslapierre/Desktop/Licence Informatique/Semestre 6/Recherche opérationnelle/Projet/OptimisationTourneeDrones/exemple.dat")

include("Projet_Base.jl")

function solve_CW(nom_fichier::String)

	data = lecture_donnees(nom_fichier)

	distanceInitiale::Array{Int64,2} = data.distance
	tailleMatrice::Int64 = data.nbVilles
	capacite::Int64 = data.capacite
	listeDemande::Array{Int64} = data.demande

	#Récupère la liste des différents couples de clients ordonnées par les gains décroissants de distance
	listeCouple::Array{Tuple{Int64,Int64}} = creationDistancier(distanceInitiale, tailleMatrice)

	resultat = []

	for i in 1:size(listeCouple,1)

    	indice1 = findfirst(x-> listeCouple[i][1] in x, resultat) #Récupère l'indice de la tournée contenant le premier client du couple
    	indice2 = findfirst(x-> listeCouple[i][2] in x, resultat) #Récupère l'indice de la tournée contenant le deuxième client du couple
		

		#Condition si les 2 clients du couple i ne sont pas dans la liste des tournées
    	if indice1 === nothing && indice2 === nothing && verifDemande([listeCouple[i][1]],[listeCouple[i][2]],listeDemande) <= capacite
        	push!(resultat, [listeCouple[i][1],listeCouple[i][2]])


		#Condition si le premier client du couple i est dans la liste des tournées mais pas le deuxième
    	elseif indice1 !== nothing && indice2 === nothing && verifDemande(resultat[indice1],[listeCouple[i][2]],listeDemande) <= capacite

			#Condition si le premier client est la première valeur de sa tournée
			if resultat[indice1][1] == listeCouple[i][1]
				prepend!(resultat[indice1],listeCouple[i][2])

			#Condition si le premier client est la dernière valeur de sa tournée
			elseif resultat[indice1][size(resultat[indice1],1)] == listeCouple[i][1]
				push!(resultat[indice1],listeCouple[i][2])
			end


		#Condition si le deuxième client du couple i est dans la liste des tournées mais pas le premier
		elseif indice1 === nothing && indice2 !== nothing && verifDemande(resultat[indice2],[listeCouple[i][1]],listeDemande) <= capacite

			#Condition si le deuxième client est la première valeur de sa tournée
			if resultat[indice2][1] == listeCouple[i][2]
				prepend!(resultat[indice2],listeCouple[i][1])

			#Condition si le deuxième client est la dernière valeur de sa tournée
			elseif resultat[indice2][size(resultat[indice2],1)] == listeCouple[i][2]
				push!(resultat[indice2],listeCouple[i][1])
			end


		#Condition si les 2 clients du couple i sont dans la liste des tournées
		elseif indice1 !== nothing && indice2 !== nothing && indice1 != indice2 && verifDemande(resultat[indice1],resultat[indice2],listeDemande) <= capacite
			
			#Condition si le premier client est la première valeur de sa tournée et le deuxième client est la première valeur de sa tournée
			if resultat[indice1][1] == listeCouple[i][1] && resultat[indice2][1] == listeCouple[i][2]
				reverse!(resultat[indice1])
				append!(resultat[indice1],resultat[indice2])
				deleteat!(resultat,indice2)

			#Condition si le premier client est la première valeur de sa tournée et le deuxième client est la dernière valeur de sa tournée
			elseif resultat[indice1][1] == listeCouple[i][1] && resultat[indice2][size(resultat[indice2],1)] == listeCouple[i][2]
				append!(resultat[indice2],resultat[indice1])
				deleteat!(resultat,indice1)

			#Condition si le premier client est la dernière valeur de sa tournée et le deuxième client est la première valeur de sa tournée
			elseif resultat[indice1][size(resultat[indice1],1)] == listeCouple[i][1] && resultat[indice2][1] == listeCouple[i][2]
				append!(resultat[indice1],resultat[indice2])
				deleteat!(resultat,indice2)

			#Condition si le premier client est la dernière valeur de sa tournée et le deuxième client est la dernière valeur de sa tournée
			elseif resultat[indice1][size(resultat[indice1],1)] == listeCouple[i][1] && resultat[indice2][size(resultat[indice2],1)] == listeCouple[i][2]
				reverse!(resultat[indice1],1)
				append!(resultat[indice2],resultat[indice1])
				deleteat!(resultat,indice1)
			end
		end
	end

	#Ajoute les clients qui n'ont pas pu être ajouté par couple
	for i in 2:(tailleMatrice)
		if findfirst(x-> i in x, resultat) === nothing
			push!(resultat,[i])
		end
	end

	distanceTournée::Array{Int64} = []
	distanceTotale::Int64 = 0

	for i in 1:size(resultat,1)
		calcul::Int64 = distanceInitiale[1,resultat[i][1]] + distanceInitiale[1,resultat[i][size(resultat[i],1)]]
		for j in 1:(size(resultat[i],1)-1)
			calcul += distanceInitiale[resultat[i][j],resultat[i][j+1]]
		end
		push!(distanceTournée,calcul)
		distanceTotale += calcul
	end

	println("Distance totale: ",distanceTotale)

	cpt::Int64 = 1
	for i in 1:size(resultat,1)
		println("Tournée ",cpt,": ",resultat[i]," => ",distanceTournée[i])
		cpt += 1
	end
end

function verifDemande(tab1::Array{Int64}, tab2::Array{Int64}, listeDemande::Array{Int64})
	resultat::Int64 = 0
	for i in 1:size(tab1,1)
		resultat += listeDemande[tab1[i]-1]
	end
	for i in 1:size(tab2,1)
		resultat += listeDemande[tab2[i]-1]
	end

	return resultat
end

function creationDistancier(distanceInitiale::Array{Int64,2}, tailleMatrice::Int64)
 
 #distancierOptimise::Array{Int64,2} = Array{Int64,2}(undef,tailleMatrice,tailleMatrice)
 distancierOptimise::Vector{Tuple{Int64,Tuple{Int64,Int64}}} = []
 

 
 #i les lignes, j les colonnes
 for i in 2:(tailleMatrice-1)
	 for j in (i+1):tailleMatrice
		 push!(distancierOptimise,(distanceInitiale[i,1] + distanceInitiale[1,j] - distanceInitiale[i,j] , (i,j)))
	 end
 end
 return map(x-> x[2],sort(distancierOptimise,rev=true)) 
end




