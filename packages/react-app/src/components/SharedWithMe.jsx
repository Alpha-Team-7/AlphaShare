import React, {useState, useEffect} from "react";
import { useContractLoader } from "eth-hooks";
import { useStaticJsonRPC } from "../hooks";
import { NETWORKS } from "../constants";



export default function SharedWithMe({ contract, tx}){
    const [file, setfile] = useState();

    useEffect(() => {
        const init = async () => {
            const sharedwithme = await contract.retreiveFilesSharedWithMe()
            setfile(sharedwithme)
            console.log(sharedwithme, "me")
        }
        if(contract){
            init()
        }
      
    }, [contract]);
    console.log(file, "file sharedwithme")
    return(
        <>
        <div>You have access to the following file</div>
        <div>{file}</div>
        </>
    )

}