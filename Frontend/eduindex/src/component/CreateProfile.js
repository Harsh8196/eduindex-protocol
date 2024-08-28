import React, { useState, useEffect } from 'react';
import '../css/CreateProfile.css'
import MetaMaskOnboarding from '@metamask/onboarding';
import web3 from '../script/web3_'
import EduxHub from '../script/EduxHub'
import { create } from 'ipfs-http-client'
import { Buffer } from 'buffer';
import { qGetProfile } from '../script/queries';
import { request } from 'graphql-request'

const projectId = process.env.REACT_APP_PROJECTID;
const projectSecret = process.env.REACT_APP_PROJECTSECRET;
const auth = 'Basic ' + Buffer.from(projectId + ':' + projectSecret).toString('base64');
const ipfsClient = create({
    host: 'ipfs.infura.io',
    port: 5001,
    protocol: 'https',
    headers: {
        authorization: auth,
    },
})

function CreateProfile() {
    const [loading, setLoading] = useState(true)
    const [accounts, setAccounts] = useState('')
    const [profilename, setProfileName] = useState('')
    const [profileId, setProfileId] = useState(0)
    const [bio, setBio] = useState('')
    const [dob, setDOB] = useState('')
    const [errorMessage, setErrorMessage] = useState('')

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

    async function uploadData() {

        try {
            const metaDataPath = await ipfsClient.add(JSON.stringify({
                "name": profilename,
                "bio": bio,
                "dob": dob
            }))
            //console.log(metaDataPath)
            await ipfsClient.pin.add(metaDataPath.path.toString())
            return metaDataPath.path.toString()

        } catch (err) {
            //console.log(err)
            setErrorMessage("Opps! Somthing went wrong.")
            return 'error'
        }

    }

    async function uploadCertificateData() {

        try {
            const metaDataPath = await ipfsClient.add(JSON.stringify({
                "coursename": "Account Abstraction Course",
            }))
            //console.log(metaDataPath)
            // //console.log({
            //     "coursename": "Account Abstraction Course",
            // })
            await ipfsClient.pin.add(metaDataPath.path.toString())
            //console.log(metaDataPath.path.toString())

        } catch (err) {
            //console.log(err)
            setErrorMessage("Opps! Somthing went wrong.")
        }

    }
    const getProfile = async () => {
        const queryParameters = {
            "to": accounts[0].toString()
        }
        const response = await request(process.env.REACT_APP_GRAPH_URL, qGetProfile, queryParameters)
        if (response.profileCreateds.length > 0) {
            setProfileId(response.profileCreateds[0].profileId)
            return response.profileCreateds[0].profileId
            // //console.log(result)
        } else {
            setProfileId(0)
            return 0
        }
    }
    const createProfile = async (event) => {
        setErrorMessage('')
        event.preventDefault()
        setLoading(false)
        try {
            setErrorMessage('Creating Profile...')
            const account = await web3.eth.accounts.privateKeyToAccount('0x' + process.env.REACT_APP_PRIVATE_KEY).address;
            //console.log(account)
            const transaction = await EduxHub.methods.createProfile([accounts[0]]);
            let myNonce = await web3.eth.getTransactionCount(account)
            let NetxNonce = web3.utils.toHex(myNonce++)
            //console.log(transaction)
            const options = {
                nonce: NetxNonce,
                to: process.env.REACT_APP_CONTRACT_ADDRESS,
                data: transaction.encodeABI(),
                gas: await transaction.estimateGas({ from: account }),
                gasPrice: 200000000
            };
            const signed = await web3.eth.accounts.signTransaction(options, '0x' + process.env.REACT_APP_PRIVATE_KEY);
            const receipt = await web3.eth.sendSignedTransaction(signed.rawTransaction);
            setErrorMessage('Profile created successfully.')
            setLoading(true)
            window.location.replace('/')
        } catch (error) {
            //console.log(error)
            setErrorMessage(error.message)
            setLoading(true)
        }
    }

    const updateProfile = async (event) => {
        setErrorMessage('')
        event.preventDefault()
        setLoading(false)
        try {
            setErrorMessage('Uploading model data to IPFS...')
            const CID = await uploadData()
            if (CID !== 'error') {
                setErrorMessage('Uploaded model data to IPFS.')
                //console.log(CID)
                setErrorMessage('Setting profile metadata...')
                const profileId = await getProfile()
                //console.log(profileId)
                let receipt = await EduxHub.methods.setProfileMetadataURI(profileId, CID).send({
                    from: accounts[0]
                })
                setErrorMessage('Profile metadata set successfully.')
                //console.log(receipt)
            }
            setLoading(true)
            window.location.replace('/')

        } catch (error) {
            //console.log(error)
            setErrorMessage(error.message)
            setLoading(true)
        }
    }

    return (
        <div className='container-fluid'>
            <div className='row d-flex justify-content-center align-items-center'>
                <div className='ViewProfileContainer'>
                    <div className="container card shadow rounded-2">
                        <div className="accordion accordion-flush mt-2" id="createFlush">
                            <div className="accordion-item">
                                <h2 className="accordion-header" id="create-heading">
                                    <button className='accordion-button fw-bold rounded-2' type="button" data-bs-toggle="collapse" data-bs-target="#create-collapse" aria-expanded="true" aria-controls="create-collapse">
                                        Create Profile
                                    </button>
                                </h2>
                                <div id="create-collapse" className='accordion-collapse collapse show' aria-labelledby="create-heading" data-bs-parent="#createFlush">
                                    <div className="accordion-body">
                                        <form onSubmit={updateProfile}>
                                            <div className="mb-3 row">
                                                <label className="col-sm-2 col-form-label">Profile Address</label>
                                                <div className="col-sm-10">
                                                    <span type='text'
                                                        className="form-control" style={{ background: "#e9ecef" }}
                                                    >{accounts[0]} </span>
                                                </div>
                                            </div>
                                            <div className="mb-3 row" hidden={profileId == 0}>
                                                <label className="col-sm-2 col-form-label">Profile Name</label>
                                                <div className="col-sm-10">
                                                    <input type="text" className="form-control"
                                                        value={profilename}
                                                        onChange={(event) => setProfileName(event.target.value)}
                                                        required
                                                    />
                                                </div>
                                            </div>
                                            <div className="mb-3 row" hidden={profileId == 0}>
                                                <label className="col-sm-2 col-form-label">Bio</label>
                                                <div className="col-sm-10">
                                                    <input type="text" className="form-control"
                                                        value={bio}
                                                        onChange={(event) => setBio(event.target.value)}
                                                        required
                                                    />
                                                </div>
                                            </div>
                                            <div className="mb-3 row" hidden={profileId == 0}>
                                                <label className="col-sm-2 col-form-label">DOB</label>
                                                <div className="col-sm-10">
                                                    <input type="date" className="form-control"
                                                        value={dob}
                                                        onChange={(event) => setDOB(event.target.value)}
                                                        required
                                                    />
                                                </div>
                                            </div>
                                            <span className="text-danger" hidden={!errorMessage}>{errorMessage}</span>
                                            <div className="mb-3 d-flex" style={{ alignItems: 'center' }} >
                                                <button type="submit" className="btn btn-CourseCatalog form-control" disabled={(!loading)} hidden={profileId == 0}>
                                                    <span className="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true" hidden={loading}></span>
                                                    Update Profile Data</button>
                                            </div>
                                            <div className="mb-3 d-flex" style={{ alignItems: 'center' }}>
                                                <button type="button" onClick={createProfile} className="btn btn-CourseCatalog form-control" disabled={(!loading)} hidden={profileId != 0}>
                                                    <span className="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true" hidden={loading}></span>
                                                    Create Profile </button>
                                            </div>
                                            {/* <div className="mb-3 d-flex" style={{ alignItems: 'center' }}>
                                                <button type="button" onClick={uploadCertificateData} className="btn btn-CourseCatalog form-control" disabled={(!loading)} >
                                                    <span className="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true" hidden={loading}></span>
                                                    Upload Certificate</button>
                                            </div> */}
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


export default CreateProfile