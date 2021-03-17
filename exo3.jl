#include("/Users/thomaslapierre/Desktop/Licence Informatique/Semestre 6/Recherche opérationnelle/Projet/exo3.jl")



include("Projet_Base.jl")



function main()
	a = Vector{Int}[ []]
	b = Int[]
	regroupement(1,6,a,10,[1,1,1,10,2,1,1,1],b)
	println(a)
	println(b)
end

#regroupement : indice actuel, indice fin, regroupement, capacité, demandei, dernière valeur ajoutée
function regroupement(actuel::Int64, n::Int64, rg::Array{Array{Int64,1},1},ca::Int64, demande::Array{Int64,1},last::Array{Int64,1}) 
	
	for i in (actuel+1):n 
		tabTmp::Array{Int64,1} = unique([last;[i]])
		
		if (peutEtreAjoute(tabTmp,demande,ca))
			if sort(tabTmp) ∉ rg
				push!(rg,tabTmp)
			end
			regroupement(actuel+1,n,rg,ca,demande,tabTmp)
		end
		
	end
	

end


function peutEtreAjoute(tableau::Array{Int64,1}, demande::Array{Int64,1}, ca::Int64)

	tab::Array{Int64,1} = []

	tailleTableau::Int64 = size(tableau,1)

	for i in 1:tailleTableau
		append!( tab, demande[tableau[i]])
	end

	if (foldl(+,tab)<=ca)
		return true
	end
	return false

end

function test()
    c::Array{Int64,2} = [  0 334 262 248 277 302;
                         334   0 118 103 551 105;
                         262 118   0 31  517 180;
                         248 103 31    0 495 152;
                         277 551 517 495   0 476;
                         302 105 180 152 476   0;];

    S::Array{Array{Int64}} = [[2],[2,3],[2,3,4],[2,3,4,6],[2,3,5],[2,3,6],[2,4],[2,4,5],[2,4,5,6]];

    listDistance::Array{Int64} = Array{Int64}(undef, size(S,1))

    for i in 1:size(S,1)
        newC::Array{Int64,2} = c;
        newC = newC[setdiff(1:end, setdiff(2:size(c,1), S[i])),setdiff(1:end, setdiff(2:size(c,1), S[i]))];
        listDistance[i] = solveTSPExact(newC)[2];
    end
    println(listDistance)
end


