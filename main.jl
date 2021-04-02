#Thomas LAPIERRE (684J) & Alex MAINGUY (684I)


#plus le saut de dualité est important au départ plus le nombre de noeuds sera important et le problème sera dur à résoudre

include("Projet_Base.jl")

#fonction à appeler pour lancer l'optimisation par la méthode exacte
#prend l'adresse du fichier à optimiser en paramètre
function solve(nom_fichier::String)

    data = lecture_donnees(nom_fichier)
    
    listeRegroupements = Vector{Int}[ []]
	println("\nCalcul des regroupements possibles...")
    regroupement(1,data.nbVilles,listeRegroupements,data.capacite,data.demande,Int[])
    deleteat!(listeRegroupements,1)
	println(size(listeRegroupements,1)," regroupements trouvés \n")
    
    listeDistance::Array{Tuple{Array{Int64},Int64}} = [];

	println("Calcul de la distance minimale pour chaque regroupement...")
    #Calcul de la distance la plus courte pour chaque regroupement
    for i in 1:size(listeRegroupements,1)
        newC::Array{Int64,2} = data.distance;
        newC = newC[setdiff(1:end, setdiff(2:size(data.distance,1), listeRegroupements[i])),setdiff(1:end, setdiff(2:size(data.distance,1), listeRegroupements[i]))];
        push!(listeDistance,solveTSPExact(newC));
    end
	println("Calcul de la distance minimale pour chaque regroupement terminé \n")
    
    m::Model = Model(GLPK.Optimizer)

    @variable(m,x[1:size(listeRegroupements,1)], binary = true);

    @objective(m, Min, sum(listeDistance[j][2]x[j] for j in 1:size(listeRegroupements,1)));

    cConstraint::Array{Int64,2} = zeros(Int64,size(listeRegroupements,1),size(data.distance,1))

    #Création d'une matrice creuse pour la liste des regroupements et des clients
    for i in 1:size(listeRegroupements,1)
        cConstraint[CartesianIndex.(i, listeRegroupements[i])] .= 1
    end

    @constraint(m, ContrainteEtape[i=2:size(data.distance,1)], sum(cConstraint[j,i]*x[j] for j in 1:size(listeRegroupements,1)) == 1)

	println("Lancement de l'optimisation")
    optimize!(m)
   
    status = termination_status(m)

    if status == MOI.OPTIMAL
        
        println("Problème résolu à l'optimalité")
        println()
        println("Distance totale: ",objective_value(m))

        listeX::Array{Int64} = value.(m[:x])
        cpt::Int64 = 1

        for i in 1:size(listeX,1)
            if listeX[i] == 1

                map!(x -> -x,listeDistance[i][1],listeDistance[i][1])
                for j in 1:size(listeRegroupements[i],1)
                    replace!(listeDistance[i][1], (-j-1) => listeRegroupements[i][j])
                end
                while listeDistance[i][1][1] != -1
                    listeDistance[i] = (circshift(listeDistance[i][1],-1),listeDistance[i][2])
                end
                deleteat!(listeDistance[i][1],1)


                println("Tournée ",cpt,": ",listeDistance[i][1]," => ",listeDistance[i][2])
                cpt += 1
            end
        end

    elseif status == MOI.INFEASIBLE
        println("Problème non-borné")

    elseif status == MOI.INFEASIBLE_OR_UNBOUNDED
        println("Problème impossible")
    end

end

#regroupement : indice actuel, indice fin, regroupement, capacité, demandei, dernière valeur ajoutée
function regroupement(actuel::Int64, n::Int64, rg::Array{Array{Int64,1},1},ca::Int64, demande::Array{Int64,1},last::Array{Int64,1}) 
    
    for i in (actuel+1):n 
        tabTmp::Array{Int64,1} = unique([last;[i]])
        
        if (peutEtreAjoute(tabTmp,demande,ca))
            if sort(tabTmp) ∉ rg
                push!(rg,tabTmp)
	            regroupement(actuel+1,n,rg,ca,demande,tabTmp)
            end
        end
        
    end
    

end

function peutEtreAjoute(tableau::Array{Int64,1}, demande::Array{Int64,1}, ca::Int64)

    tab::Array{Int64,1} = []

    tailleTableau::Int64 = size(tableau,1)

    for i in 1:tailleTableau
        append!( tab, demande[tableau[i]-1])
    end

    if (foldl(+,tab)<=ca)
        return true
    end
    return false

end

