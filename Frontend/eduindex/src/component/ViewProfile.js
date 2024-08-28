import React, { useState, useEffect } from 'react';
import '../css/ViewProfile.css'
import MetaMaskOnboarding from '@metamask/onboarding';
import EduxHub from '../script/EduxHub'
import { LoadingContainer } from "./Loading"
import { qGetProfile, gGetProfileMetadata } from '../script/queries';
import { request } from 'graphql-request'

const projectId = process.env.REACT_APP_PROJECTID;
const projectSecret = process.env.REACT_APP_PROJECTSECRET;

function ViewProfile() {
    const [accounts, setAccounts] = useState('')
    const [isLoading, setIsLoading] = useState(false)
    const [profilename, setProfileName] = useState('')
    const [profileId, setProfileId] = useState(0)
    const [profileImage, setProfileImage] = useState('')
    const [bio, setBio] = useState('')
    const [dob, setDOB] = useState('')

    useEffect(() => {
        handleaccounts()
    }, []);

    const handleaccounts = async () => {
        function handleNewAccounts(newAccounts) {
            setAccounts(newAccounts);
        }
        if (MetaMaskOnboarding.isMetaMaskInstalled()) {
            await window.ethereum
                .request({ method: 'eth_requestAccounts' })
                .then(handleNewAccounts);
            await window.ethereum.on('accountsChanged', handleNewAccounts);
            return async () => {
                await window.ethereum.off('accountsChanged', handleNewAccounts);
            };
        }
    }

    useEffect(() => {
        if (accounts.length > 0) {
            getProfile()
        }

    }, [accounts])

    useEffect(() => {
        if (profileId > 0) {
            getProfileMetadata()
        }

    }, [profileId])

    const getProfile = async () => {
        const queryParameters = {
            "to": accounts[0].toString()
        }
        const response = await request(process.env.REACT_APP_GRAPH_URL, qGetProfile, queryParameters)
        if (response.profileCreateds.length > 0) {
            setProfileId(response.profileCreateds[0].profileId)
            const qResult = await EduxHub.methods.tokenURI(response.profileCreateds[0].profileId).call()
            let result = await fetch(qResult)
            result = await result.json()
            setProfileImage(result.image)
            // //console.log(result)
        } else {
            setProfileId(0)
        }
        //console.log(response)
    }

    const getProfileMetadata = async () => {
        const queryParameters = {
            "profileId": profileId
        }
        let response = await request(process.env.REACT_APP_GRAPH_URL, gGetProfileMetadata, queryParameters)
        if (response.profileMetadataSets.length > 0) {
            response = await fetch('https://ipfs.infura.io:5001/api/v0/get?arg=' + response.profileMetadataSets[0].metadata, {
                method: 'POST',
                headers: {
                    "Authorization": "Basic " + btoa(projectId + ":" + projectSecret)
                }
            })
            let IPFSData = await response.text()
            const startIndex = IPFSData.indexOf("{")
            const endIndex = IPFSData.indexOf("}")
            const data = JSON.parse(IPFSData.substring(startIndex, endIndex + 1))
            setProfileName(data["name"])
            setBio(data["bio"])
            setDOB(data["dob"])
            //console.log(data)
            // //console.log(result)
            setIsLoading(true)
        } else {
            setIsLoading(true)
        }

    }

    return (
        <div className='container-fluid'>
            <LoadingContainer isLoading={isLoading} />
            <div className='row d-flex justify-content-center align-items-center'>
                <div className='ViewProfileContainer mb-2' hidden={!isLoading}>
                    <div className="container card shadow rounded-2">
                        <div className="accordion accordion-flush mt-2" id="createFlush">
                            <div className="accordion-item">
                                <h2 className="accordion-header" id="create-heading">
                                    <button className='accordion-button fw-bold rounded-2' type="button" data-bs-toggle="collapse" data-bs-target="#create-collapse" aria-expanded="true" aria-controls="create-collapse">
                                        View Profile
                                    </button>
                                </h2>
                                <div id="create-collapse" className='accordion-collapse collapse show' aria-labelledby="create-heading" data-bs-parent="#createFlush">
                                    <div className="accordion-body">
                                        <form>
                                            <div className="mb-3 row align-items-center justify-content-center">
                                                <img src={profileImage} className="profile-image" />
                                            </div>
                                            <div className="mb-3 row">
                                                <label className="col-sm-2 col-form-label">Profile Address</label>
                                                <div className="col-sm-10">
                                                    <span type='text'
                                                        className="form-control" style={{ background: "#e9ecef" }}
                                                    >{accounts[0]} </span>
                                                </div>
                                            </div>
                                            <div className="mb-3 row">
                                                <label className="col-sm-2 col-form-label">Profile Id</label>
                                                <div className="col-sm-10">
                                                    <span type='text'
                                                        className="form-control" style={{ background: "#e9ecef" }}
                                                    >{profileId} </span>
                                                </div>
                                            </div>
                                            <div className="mb-3 row">
                                                <label className="col-sm-2 col-form-label">Profile Name</label>
                                                <div className="col-sm-10">
                                                    <input type="text" readOnly className="form-control-plaintext" value={profilename} />
                                                </div>
                                            </div>
                                            <div className="mb-3 row">
                                                <label className="col-sm-2 col-form-label">Bio</label>
                                                <div className="col-sm-10">
                                                    <input type="text" readOnly className="form-control-plaintext" value={bio} />
                                                </div>
                                            </div>
                                            <div className="row">
                                                <label className="col-sm-2 col-form-label">DOB</label>
                                                <div className="col-sm-10">
                                                    <input type="text" readOnly className="form-control-plaintext" value={dob} />
                                                </div>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    )
}


export default ViewProfile