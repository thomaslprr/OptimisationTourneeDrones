#include("/Users/thomaslapierre/Desktop/Licence Informatique/Semestre 6/Recherche opérationnelle/Projet/OptimisationTourneeDrones/exo3.jl")
#solve("/Users/thomaslapierre/Desktop/Licence Informatique/Semestre 6/Recherche opérationnelle/Projet/OptimisationTourneeDrones/A/VRPA10.dat")



include("Projet_Base.jl")


function solve(nom_fichier::String)

    data = lecture_donnees(nom_fichier)
    
    listeRegroupements = Vector{Int}[ []]
    
    regroupement(1,data.nbVilles,listeRegroupements,data.capacite,data.demande,Int[])
    deleteat!(listeRegroupements,1)
    
    listeDistance::Array{Int64} = Array{Int64}(undef, size(listeRegroupements,1))

    for i in 1:size(listeRegroupements,1)
        newC::Array{Int64,2} = data.distance;
        newC = newC[setdiff(1:end, setdiff(2:size(data.distance,1), listeRegroupements[i])),setdiff(1:end, setdiff(2:size(data.distance,1), listeRegroupements[i]))];
        listeDistance[i] = solveTSPExact(newC)[2];
    end
    
    m::Model = Model(GLPK.Optimizer)

    @variable(m,x[1:size(listeRegroupements,1)], binary = true);

    @objective(m, Min, sum(listeDistance[j]x[j] for j in 1:size(listeRegroupements,1)));

    cConstraint::Array{Int64,2} = zeros(Int64,size(listeRegroupements,1),size(data.distance,1))

    for i in 1:size(listeRegroupements,1)
        cConstraint[CartesianIndex.(i, listeRegroupements[i])] .= 1
    end

    @constraint(m, ContrainteEtape[i=2:size(data.distance,1)], sum(cConstraint[j,i]*x[j] for j in 1:size(listeRegroupements,1)) == 1)

    optimize!(m)
   
    status = termination_status(m)

    if status == MOI.OPTIMAL
        println("Problème résolu à l'optimalité")

        println("z = ",objective_value(m))

        listeX::Array{Int64} = value.(m[:x])
        cpt::Int64 = 1

        for i in 1:size(listeX,1)
            if listeX[i] == 1
                println("Tournée ",cpt,": ",listeRegroupements[i])
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
            end
            regroupement(actuel+1,n,rg,ca,demande,tabTmp)
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

