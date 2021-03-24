#include("/Users/thomaslapierre/Desktop/Licence Informatique/Semestre 6/Recherche opérationnelle/Projet/OptimisationTourneeDrones/exo4.jl")
#creationDistancier("/Users/thomaslapierre/Desktop/Licence Informatique/Semestre 6/Recherche opérationnelle/Projet/OptimisationTourneeDrones/A/VRPA10.dat")
#creationDistancier("/Users/thomaslapierre/Desktop/Licence Informatique/Semestre 6/Recherche opérationnelle/Projet/OptimisationTourneeDrones/exemple.dat")


function creationDistancier(nom_fichier::String)

 data = lecture_donnees(nom_fichier)
 
 distanceInitiale::Array{Int64,2} = data.distance
 
 tailleMatrice::Int64 = data.nbVilles 

 
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




